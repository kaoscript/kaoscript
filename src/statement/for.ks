class ForStatement extends Statement {
	private late {
		@bodyBlock: Block
		@bodyScope: Scope
		@else: Boolean					= false
		@elseBlock: Block
		@elseName: String?
		@elseScope: Scope?
		@iterations: IterationNode[]	= []
		@manyIterations: Boolean
	}
	override analyse() { # {{{
		@bodyScope = @scope!?

		for var data in @data.iterations {
			var iteration = IterationNode.fromAST(data, this, @bodyScope)
				..analyse()

			@bodyScope = iteration.getBodyScope()

			@iterations.push(iteration)
		}

		@manyIterations = @iterations.length > 1

		@bodyBlock = $compile.block(@data.body, this, @bodyScope)
		@bodyBlock.analyse()

		if ?@data.else {
			@else = true

			@elseScope = @newScope(@scope!?, ScopeType.InlineBlock)

			@elseBlock = $compile.block(@data.else, this, @elseScope)
			@elseBlock.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		for var iteration in @iterations {
			iteration.prepare(AnyType.NullableUnexplicit, targetMode)
		}

		@bodyBlock.prepare(target)

		for var iteration in @iterations {
			iteration.releaseVariables()
		}

		if @else {
			@elseBlock.prepare(target)

			if @manyIterations {
				@elseName = @scope.acquireTempName(false)

				@iterations.last().setElseTest(ElseTestKind.Setter)
			}

			var trueInferables = @bodyScope.listUpdatedInferables()
			var falseInferables = @elseScope.listUpdatedInferables()

			for var inferable, name of trueInferables {
				var trueType = inferable.type

				if ?falseInferables[name] {
					var falseType = falseInferables[name].type

					if trueType.equals(falseType) {
						@scope.updateInferable(name, inferable, this)
					}
					else {
						@scope.updateInferable(name, {
							isVariable: inferable.isVariable
							type: Type.union(@scope, trueType, falseType)
						}, this)
					}
				}
				else if inferable.isVariable && @scope.hasVariable(name) {
					@scope.replaceVariable(name, inferable.type, true, false, this)
				}
			}

			for var inferable, name of falseInferables when !?trueInferables[name] {
				if inferable.isVariable && @scope.hasVariable(name) {
					@scope.replaceVariable(name, inferable.type, true, false, this)
				}
			}
		}
		else {
			for var inferable, name of @bodyScope.listUpdatedInferables() {
				if inferable.isVariable && @scope.hasVariable(name) {
					@scope.replaceVariable(name, inferable.type, true, false, this)
				}
			}
		}
	} # }}}
	override translate() { # {{{
		for var iteration in @iterations {
			iteration.translate()
		}

		@bodyBlock.translate()

		@elseBlock.translate() if @else
	} # }}}
	getElseName() => @elseName
	hasElse() => @else
	hasManyIterations() => @manyIterations
	override isExit(mode) { # {{{
		if mode ~~ .Always {
			return @else && @bodyBlock.isExit(mode) && @elseBlock.isExit(mode)
		}
		else {
			return @bodyBlock.isExit(mode) || (@else && @elseBlock.isExit(mode))
		}
	} # }}}
	override isJumpable() => true
	override isLoop() => true
	override setExitLabel(label) { # {{{
		@bodyBlock.setExitLabel(label)

		if @else {
			@elseBlock.setExitLabel(label)
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		if @manyIterations {
			var mut ctrl = fragments

			if @else {
				fragments.line(`let \(@elseName) = true`)
			}

			var stack = []

			for var iteration in @iterations {
				var { close, fragments % writer } = iteration.toIterationFragments(ctrl)

				stack.push(close)

				ctrl = writer
			}

			ctrl.compile(@bodyBlock)

			for var close in stack down {
				close()
			}

			if @else {
				fragments
					.newControl()
					.code(`if(\(@elseName))`)
					.step()
					.compile(@elseBlock)
					.done()
			}
		}
		else {
			var { close, fragments % ctrl } = @iterations[0].toIterationFragments(fragments)

			ctrl.compile(@bodyBlock)

			if var elseCtrl ?= close() {
				elseCtrl
					.step()
					.code('else')
					.step()
					.compile(@elseBlock)
					.done()
			}
		}
	} # }}}
}
