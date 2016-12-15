class ExpressionStatement extends Statement {
	private {
		_expression
		_variable			= ''
	}
	ExpressionStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._expression = $compile.expression(this._data, this)
	} // }}}
	assignment(data, expression) { // {{{
		if data.left.kind == Kind::Identifier && !this._scope.hasVariable(data.left.name) {
			if !expression.isAssignable() || this._variable.length {
				this._variables.push(data.left.name)
			}
			else {
				this._variable = data.left.name
			}
			
			$variable.define(this, this._scope, data.left, $variable.kind(data.right.type), data.right.type)
		}
	} // }}}
	fuse() { // {{{
		this._expression.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._expression.isAssignable() {
			if this._variables.length {
				fragments.newLine().code($variable.scope(this) + this._variables.join(', ')).done()
			}
			
			let line = fragments.newLine()
			
			if this._variable.length {
				line.code($variable.scope(this))
			}
			
			if this._expression.toAssignmentFragments? {
				this._expression.toAssignmentFragments(line)
			}
			else {
				this._expression.toFragments(line, Mode::None)
			}
			
			line.done()
		}
		else if this._expression.toStatementFragments? {
			if this._variable.length {
				this._variables.unshift(this._variable)
			}
			
			if this._variables.length {
				fragments.newLine().code($variable.scope(this) + this._variables.join(', ')).done()
			}
			
			this._expression.toStatementFragments(fragments, Mode::None)
		}
		else {
			if this._variables.length {
				fragments.newLine().code($variable.scope(this) + this._variables.join(', ')).done()
			}
			
			let line = fragments.newLine()
			
			if this._variable.length {
				line.code($variable.scope(this))
			}
			
			line.compile(this._expression, Mode::None).done()
		}
		
		for afterward in this._afterwards {
			afterward.toAfterwardFragments(fragments)
		}
	} // }}}
}