class DestroyStatement extends Statement {
	private {
		_expression
		/* _hasVariable: Boolean	= false */
		_identifier: Boolean		= false
		_type: Type
		_variable: Variable
	}
	/* analyse() { // {{{
		@expression = $compile.expression(@data.variable, this)

		@expression.analyse()

		if @data.variable.kind == NodeKind::Identifier {
			@hasVariable = true

			@scope.removeVariable(@data.variable.name)
		}
	} // }}}
	prepare() { // {{{
		if @hasVariable {
			@type = @scope.getVariable(@data.variable.name, -1).getRealType()
		}
		else {
			@expression.prepare()
		}
	} // }}}
	translate() { // {{{
		@expression.translate()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @hasVariable && (type = @type.discardReference()).isClass() && type.type().hasDestructors() {
			fragments.newLine().code(type.path(), '.__ks_destroy(').compile(@expression).code(')').done()
		}

		if @expression is IdentifierLiteral {
			fragments.newLine().compile(@expression).code(' = undefined').done()
		}
		else {
			fragments.newLine().code('delete ').compile(@expression).done()
		}
	} // }}} */
	analyse() { // {{{
		if @data.variable.kind == NodeKind::Identifier {
			if !@scope.hasVariable(@data.variable.name) {
				ReferenceException.throwNotDefined(@data.variable.name, this)
			}

			@identifier = true

			@scope.removeVariable(@data.variable.name)
		}
		else {
			@expression = $compile.expression(@data.variable, this)

			@expression.analyse()
		}
	} // }}}
	prepare() { // {{{
		if @identifier {
			/* @type = @scope.getVariable(@data.variable.name, -1).getRealType() */
			@type = @scope.getVariable(@data.variable.name, @scope.line() - 1).getRealType()
		}
		else {
			@expression.prepare()
		}
	} // }}}
	translate() { // {{{
		if !@identifier {
			@expression.translate()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @identifier {
			const type = @type.discardReference()
			if type.isClass() && type.type().hasDestructors() {
				fragments.newLine().code(type.path(), '.__ks_destroy(').code(@scope.getRenamedVariable(@data.variable.name)).code(')').done()
			}

			fragments.newLine().code(@scope.getRenamedVariable(@data.variable.name)).code(' = undefined').done()
		}
		else {
			fragments.newLine().code('delete ').compile(@expression).done()
		}
	} // }}}
}