abstract class Statement extends AbstractNode {
	private {
		_afterwards: Array	= []
		_variables: Array	= []
	}
	constructor(@data, @parent, @scope = parent.scope()) { // {{{
		super(data, parent, scope)
		
		@options = Attribute.configure(data, parent._options, AttributeTarget::Statement)
	} // }}}
	afterward(node) { // {{{
		@afterwards.push(node)
	} // }}}
	assignment(data, expression) { // {{{
		if data.left.kind == NodeKind::Identifier {
			let variable
			if variable ?= @scope.getVariable(data.left.name) {
				if variable.isImmutable() {
					SyntaxException.throwImmutable(data.left.name, this)
				}
			}
			else {
				@variables.push(data.left.name)
			
				@scope.define(data.left.name, false, this)
			}
		}
	} // }}}
	isAwait() => false
	isExit() => false
	isReturning(type: Type) => true
	statement() => this
	toFragments(fragments, mode) { // {{{
		const variables = this.variables()
		if variables.length != 0 {
			fragments.newLine().code($runtime.scope(this) + variables.join(', ')).done()
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
	variables() => @variables
}

include {
	../statement/break
	../statement/class
	../statement/continue
	../statement/dependency
	../statement/destroy
	../statement/do-until
	../statement/do-while
	../statement/enum
	../statement/export
	../statement/expression
	../statement/for-from
	../statement/for-in
	../statement/for-of
	../statement/for-range
	../statement/function
	../statement/if
	../statement/implement
	../statement/import
	../statement/include
	../statement/namespace
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