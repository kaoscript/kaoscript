abstract class Statement extends AbstractNode {
	private {
		_afterwards: Array		= []
		_assignments: Array		= []
		_attributeDatas			= {}
	}
	constructor(@data, @parent, @scope = parent.scope()) { // {{{
		super(data, parent, scope)

		@options = Attribute.configure(data, parent._options, true, AttributeTarget::Statement)
	} // }}}
	afterward(node) { // {{{
		@afterwards.push(node)
	} // }}}
	assignment(data, expression) { // {{{
		if data.left.kind == NodeKind::Identifier {
			let variable
			if variable ?= @scope.getVariable(data.left.name) {
				if variable.isImmutable() {
					ReferenceException.throwImmutable(data.left.name, this)
				}
			}
			else {
				@assignments.push(data.left.name)

				@scope.define(data.left.name, false, this)

				return [data.left.name]
			}
		}
	} // }}}
	assignments() => @assignments
	bindingScope() => @scope
	export(recipient)
	getAttributeData(key: AttributeData) => @attributeDatas[key]
	isAwait() => false
	isExit() => false
	isExportable() => false
	includePath() => @parent.includePath()
	isReturning(type: Type) => true
	setAttributeData(key: AttributeData, data) { // {{{
		@attributeDatas[key] = data
	} // }}}
	statement() => this
	target() => @options.target
	toFragments(fragments, mode) { // {{{
		const variables = this.assignments()
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
}

include {
	'../statement/break'
	'../statement/class'
	'../statement/continue'
	'../statement/destroy'
	'../statement/disclose'
	'../statement/do-until'
	'../statement/do-while'
	'../statement/enum'
	'../statement/export'
	'../statement/expression'
	'../statement/for-from'
	'../statement/for-in'
	'../statement/for-of'
	'../statement/for-range'
	'../statement/function'
	'../statement/if'
	'../statement/implement'
	'../statement/import'
	'../statement/dependency'
	'../statement/include'
	'../statement/namespace'
	'../statement/return'
	'../statement/switch'
	'../statement/throw'
	'../statement/try'
	'../statement/type'
	'../statement/unless'
	'../statement/until'
	'../statement/variable'
	'../statement/while'
}