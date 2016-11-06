class Statement extends AbstractNode {
	private {
		_afterwards	: Array	= []
		_variables	: Array	= []
	}
	afterward(node) { // {{{
		this._afterwards.push(node)
	} // }}}
	assignment(data, allowAssignement = false) { // {{{
		if data.left.kind == Kind::Identifier && !this._scope.hasVariable(data.left.name) {
			this._variables.push(data.left.name)
			
			$variable.define(this._scope, data.left, $variable.kind(data.right.type), data.right.type)
		}
	} // }}}
	compile(statements) { // {{{
		for statement in statements {
			statement.analyse()
		}
		
		for statement in statements {
			statement.fuse()
		}
	} // }}}
	isAsync() => false
	statement() => this
	toFragments(fragments, mode) { // {{{
		if this._variables.length {
			fragments.newLine().code($variable.scope(this) + this._variables.join(', ')).done()
		}
		
		if r ?= this.toStatementFragments(fragments, mode) {
			r.afterwards = this._afterwards
			
			return r
		}
		else {
			for afterward in this._afterwards {
				afterward.toAfterwardFragments(fragments)
			}
		}
	} // }}}
}

include {
	../statement/break
	../statement/class
	../statement/continue
	../statement/do-until
	../statement/do-while
	../statement/enum
	../statement/export
	../statement/expression
	../statement/extern
	../statement/extern-require
	../statement/for-from
	../statement/for-in
	../statement/for-of
	../statement/for-range
	../statement/function
	../statement/if
	../statement/implement
	../statement/import
	../statement/include
	../statement/require
	../statement/require-extern
	../statement/return
	../statement/switch
	../statement/throw
	../statement/try
	../statement/type
	../statement/unless
	../statement/until
	../statement/variable
	../statement/while
}