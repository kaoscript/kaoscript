class ObjectComprehension extends Expression {
	private late {
		@bodyScope: Scope
		@iteration: IterationNode
		@name
		@reusable: Boolean			= false
		@reuseName: String?			= null
		@type: Type
		@value
		@varname: String			= 'o'
	}
	override analyse() { # {{{
		@iteration = IterationNode.fromAST(@data.iteration, this, @scope)
			..analyse()

		@bodyScope = @iteration.getBodyScope()

		@value = $compile.expression(@data.value, this, @bodyScope)
			..initiate()
			..analyse()

		if @data.name.kind == NodeKind.ComputedPropertyName {
			@name = $compile.expression(@data.name.expression, this, @bodyScope)
		}
		else {
			@name = $compile.expression(@data.name, this, @bodyScope)
		}

		@name
			..initiate()
			..analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@type = ObjectType.new(@scope)

		@iteration.prepare(AnyType.NullableUnexplicit, targetMode)

		@value.prepare(AnyType.NullableUnexplicit)
		@name.prepare(AnyType.NullableUnexplicit)

		@type
			..setKeyType(@name.type())
			..setRestType(@value.type())
			..flagComplete()
	} # }}}
	override translate() { # {{{
		@iteration.translate()
		@value.translate()
		@name.translate()
	} # }}}
	acquireReusable(acquire) { # {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}
	} # }}}
	assignTempVariables(scope: Scope)
	hasElse() => false
	isComputed() => true
	override isUsingVariable(name) { # {{{
		return	@iteration.isUsingVariable(name) ||
				@value.isUsingVariable(name) ||
				@name.isUsingVariable(name)
	} # }}}
	override listNonLocalVariables(scope, variables) { # {{{
		@iteration.listNonLocalVariables(scope, variables)
		@value.listNonLocalVariables(scope, variables)
		@name.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	releaseReusable() { # {{{
		@scope.releaseTempName(@reuseName) if ?@reuseName
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else {
			if @isUsingVariable('o') {
				if !@isUsingVariable('d') {
					@varname = 'd'
				}
				else if !@isUsingVariable('_') {
					@varname = '_'
				}
				else {
					@varname = '__ks__'
				}
			}

			fragments.code('(() =>')

			var block = fragments.newBlock()

			block.line($const(this), @varname, ' = new ', $runtime.object(this), '()')

			var { close, fragments % ctrl } = @iteration.toIterationFragments(block)

			ctrl.newLine().code(`\(@varname)[`).compile(@name).code(`] = `).compile(@value).done()

			close()

			block.line(`return \(@varname)`).done()

			fragments.code(')()')
		}
	} # }}}
	toReusableFragments(fragments) { # {{{
		fragments
			.code(@reuseName, $equals)
			.compile(this)

		@reusable = true
	} # }}}
	type() => @type
}
