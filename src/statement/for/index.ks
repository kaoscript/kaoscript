class ForStatement extends Statement {
	private late {
		@bodyBlock
		@bodyScope: Scope
		@else: Boolean					= false
		@elseBlock
		@elseName: String?
		@elseScope: Scope?
		@iterations: IterationNode[]	= []
		@manyIterations: Boolean
	}
	override analyse() { # {{{
		@bodyScope = @scope!?

		for var data in @data.iterations {
			var iteration = match data.kind {
				IterationKind.Array => ArrayIteration.new(data, this, @bodyScope)
				IterationKind.From => FromIteration.new(data, this, @bodyScope)
				IterationKind.Object => ObjectIteration.new(data, this, @bodyScope)
				IterationKind.Range => RangeIteration.new(data, this, @bodyScope)
				// TODO remove else
				else => throw NotImplementedException.new()
			}

			iteration.analyse()

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
	override isJumpable() => true
	override isLoop() => true
	toStatementFragments(fragments, mode) { # {{{
		if @manyIterations {
			var mut ctrl = fragments

			if @else {
				fragments.line(`let \(@elseName) = true`)
			}

			var stack = []

			for var iteration in @iterations {
				var { close, fragments } = iteration.toIterationFragments(ctrl)

				stack.push(close)

				ctrl = fragments
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

enum ElseTestKind {
	None
	Setter
}

enum LoopKind {
	Ordered
	Static
	Unknown
}

enum OrderKind {
	Ascending
	Descending
	None
}

abstract class IterationNode extends AbstractNode {
	protected late {
		@bindingScope: Scope
		@bodyScope: Scope
		@elseTest: ElseTestKind				= .None
	}
	abstract {
		releaseVariables(): Void
		toIterationFragments(fragments)
	}
	assignTempVariables(scope: Scope): Void { # {{{
		@parent.assignTempVariables(scope)
	} # }}}
	getBodyScope(): valueof @bodyScope
	hasElse(): Boolean => @parent.hasElse()
	setElseTest(@elseTest): Void
	protected {
		close(fragments, elseCtrl?) { # {{{
			fragments.done()

			if ?elseCtrl {
				if @parent.hasManyIterations() {
					elseCtrl.done()
				}
				else {
					return elseCtrl
				}
			}

			return null
		} # }}}
	}
}

include {
	'./array.ks'
	'./from.ks'
	'./object.ks'
	'./range.ks'
}