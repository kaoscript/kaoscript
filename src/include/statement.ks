class Statement extends AbstractNode {
	private {
		_afterwards	: Array	= []
		_variables	: Array	= []
	}
	$create(data, parent, scope = parent.scope()) { // {{{
		@data = data
		@parent = parent
		@scope = scope
		@options = $attribute.apply(data, parent._options)
	} // }}}
	afterward(node) { // {{{
		@afterwards.push(node)
	} // }}}
	assignment(data, allowAssignement = false) { // {{{
		if data.left.kind == Kind::Identifier && !@scope.hasVariable(data.left.name) {
			@variables.push(data.left.name)
			
			$variable.define(this, @scope, data.left, $variable.kind(data.right.type), data.right.type)
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
		if @variables.length {
			fragments.newLine().code($variable.scope(this) + @variables.join(', ')).done()
		}
		
		if r ?= this.toStatementFragments(fragments, mode) {
			r.afterwards = @afterwards
			
			return r
		}
		else {
			for afterward in @afterwards {
				afterward.toAfterwardFragments(fragments)
			}
		}
	} // }}}
}

include {
	../statement/break
	../statement/class
	../statement/continue
	../statement/destroy
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