class DropStatement extends Statement {
	private late {
		@expression
		@identifier: Boolean		= false
		@type: Type
	}
	initiate() { # {{{
		if @data.variable.kind == NodeKind.Identifier {
			if !@scope.hasVariable(@data.variable.name) {
				ReferenceException.throwNotDefined(@data.variable.name, this)
			}

			@identifier = true

			@scope.removeVariable(@data.variable.name)
		}
		else {
			@expression = $compile.expression(@data.variable, this)


		}
	} # }}}
	analyse() { # {{{
		if !@identifier {
			@expression.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @identifier {
			@type = @scope.getVariable(@data.variable.name, @scope.line() - 1).getRealType()
		}
		else {
			@expression.prepare(AnyType.NullableUnexplicit)
		}
	} # }}}
	translate() { # {{{
		if !@identifier {
			@expression.translate()
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		if @identifier {
			var variable = @scope.getVariable(@data.variable.name, @scope.line() - 1)
			var type = @type.discardReference()

			if type.isClass() && type.type().hasDestructors() {
				fragments.newLine().code(type.path(), '.__ks_destroy(').compile(variable).code(')').done()
			}

			fragments.newLine().compile(variable).code(' = void 0').done()
		}
		else {
			fragments.newLine().code('delete ').compile(@expression).done()
		}
	} # }}}
}
