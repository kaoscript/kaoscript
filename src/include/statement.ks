abstract class Statement extends AbstractNode {
	private {
		_afterwards: Array		= []
		_assignments: Array		= []
		_attributeDatas			= {}
		_line: Number
	}
	constructor(@data, @parent, @scope = parent.scope()) { // {{{
		super(data, parent, scope)

		@options = Attribute.configure(data, parent._options, AttributeTarget::Statement, super.file())
		@line = data.start.line
	} // }}}
	constructor(@data, @parent, scope: Scope, kind: ScopeType) { // {{{
		super(data, parent, scope, kind)

		@options = Attribute.configure(data, parent._options, AttributeTarget::Statement, super.file())
		@line = data.start.line
	} // }}}
	addAssignments(variables) { // {{{
		@assignments.pushUniq(...variables)
	} // }}}
	addInitializableVariable(variable, node) => @parent.addInitializableVariable(variable, this)
	afterward(node) { // {{{
		@afterwards.push(node)
	} // }}}
	assignTempVariables(scope: Scope) { // {{{
		scope.commitTempVariables(@assignments)
	} // }}}
	assignments() => @assignments
	checkReturnType(type: Type)
	defineVariables(left, scope, expression = null, leftMost = false) { // {{{
		for const name in left.listAssignments([]) {
			if const variable = scope.getVariable(name) {
				if variable.isImmutable() {
					ReferenceException.throwImmutable(name, this)
				}
			}
			else if @options.rules.noUndefined {
				ReferenceException.throwNotDefined(name, this)
			}
			else {
				if !scope.hasDeclaredVariable(name) {
					@assignments.push(name)
				}

				@scope.define(name, false, this)
			}
		}
	} // }}}
	export(recipient)
	getAttributeData(key: AttributeData) => @attributeDatas[key]
	includePath() => @parent.includePath()
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode)
	isAwait() => false
	isCascade() => false
	isExit() => false
	isExportable() => false
	isInitializingInstanceVariable(name) => false
	isJumpable() => false
	isLateInitializable() => false
	isLoop() => false
	isUsingVariable(name) => false
	isUsingInstanceVariable(name) => false
	isUsingStaticVariable(class, varname) => false
	line() => @line
	setAttributeData(key: AttributeData, data) { // {{{
		@attributeDatas[key] = data
	} // }}}
	statement() => this
	target() => @options.target
	toDeclarationFragments(variables, fragments) { // {{{
		if variables.length != 0 {
			fragments.newLine().code($runtime.scope(this) + variables.join(', ')).done()
		}
	} // }}}
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
	'../statement/fallthrough'
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