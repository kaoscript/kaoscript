class ArrayComprehension extends Expression {
	private late {
		@bodyScope: Scope
		@iteration: IterationNode
		@reusable: Boolean			= false
		@reuseName: String?			= null
		@type: Type
		@value
		@varname: String			= 'a'
	}
	override analyse() { # {{{
		@iteration = IterationNode.fromAST(@data.iteration, this, @scope)
			..analyse()

		@bodyScope = @iteration.getBodyScope()

		@value = $compile.expression(@data.value, this, @bodyScope)
			..initiate()
			..analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@iteration.prepare(AnyType.NullableUnexplicit, targetMode)

		@value.prepare(AnyType.NullableUnexplicit)

		if @value.isSpread() {
			@type = Type.arrayOf(@value.type().parameter(), @scope)
		}
		else {
			@type = Type.arrayOf(@value.type(), @scope)
		}

		@type.flagComplete()
	} # }}}
	override translate() { # {{{
		@iteration.translate()
		@value.translate()
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
		return @iteration.isUsingVariable(name) || @value.isUsingVariable(name)
	} # }}}
	override listNonLocalVariables(scope, variables) { # {{{
		@iteration.listNonLocalVariables(scope, variables)
		@value.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	releaseReusable() { # {{{
		@scope.releaseTempName(@reuseName) if ?@reuseName
	} # }}}
	toDeclarationFragments(variables, fragments) { # {{{
		if variables.length != 0 {
			fragments.newLine().code($runtime.scope(this) + variables.join(', ')).done()
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else {
			if @isUsingVariable('a') {
				if !@isUsingVariable('l') {
					@varname = 'l'
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

			block.line($const(this), @varname, ' = []')

			var { close, fragments % ctrl } = @iteration.toIterationFragments(block)

			ctrl.newLine().code(`\(@varname).push(`).compile(@value).code(')').done()

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
