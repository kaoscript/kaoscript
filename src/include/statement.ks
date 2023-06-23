abstract class Statement extends AbstractNode {
	private {
		@afterwards: Array		= []
		@assignments: Array		= []
		@attributeDatas			= {}
		@beforehands: Array		= []
		@line: Number
	}
	constructor(@data, @parent, @scope = parent.scope()) { # {{{
		super(data, parent, scope)

		@options = Attribute.configure(data, parent._options, AttributeTarget.Statement, super.file())
		@line = data.start.line
	} # }}}
	constructor(@data, @parent, scope: Scope, kind: ScopeType) { # {{{
		super(data, parent, scope, kind)

		@options = Attribute.configure(data, parent._options, AttributeTarget.Statement, super.file())
		@line = data.start.line
	} # }}}
	addAfterward(node) { # {{{
		@afterwards.push(node)
	} # }}}
	addBeforehand(node) { # {{{
		@beforehands.push(node)
	} # }}}
	addAssignments(variables) { # {{{
		@assignments.pushUniq(...variables)
	} # }}}
	addInitializableVariable(variable, node) => @parent.addInitializableVariable(variable, this)
	assignTempVariables(scope: Scope) { # {{{
		scope.commitTempVariables(@assignments)
	} # }}}
	assignments() => @assignments
	defineVariables(left: AbstractNode, names: Array<String>, scope: Scope, expression? = null, leftMost: Boolean = false) { # {{{
		for var name in names {
			if var variable ?= scope.getVariable(name) {
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
	} # }}}
	defineVariables(left: AbstractNode, scope: Scope, expression? = null, leftMost: Boolean = false) { # {{{
		var assignments = left.listAssignments([]).map(({ name }, ...) => name)

		@defineVariables(left, assignments, scope, expression, leftMost)
	} # }}}
	export(recipient)
	export(recipient, enhancement: Boolean) { # {{{
		if !enhancement {
			@export(recipient)
		}
	} # }}}
	getAttributeData(key: AttributeData) => @attributeDatas[key]
	includePath() => @parent.includePath()
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode)
	isAwait() => false
	isCascade() => false
	isEnhancementExport() => false
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
	listNonLocalVariables(scope: Scope, variables: Array) => variables
	postInitiate()
	prepare(target: Type, index: Number, length: Number) => @prepare(target)
	recipient() => @parent.recipient()
	setAttributeData(key: AttributeData, data) { # {{{
		@attributeDatas[key] = data
	} # }}}
	statement() => this
	target() => @options.target
	toDeclarationFragments(variables, fragments) { # {{{
		if variables.length != 0 {
			fragments.newLine().code($runtime.scope(this) + variables.join(', ')).done()
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		var variables = @assignments()
		if #variables {
			fragments.newLine().code($runtime.scope(this) + variables.join(', ')).done()
		}

		if #@beforehands {
			for var beforehand in @beforehands {
				beforehand.toBeforehandFragments(fragments, mode)
			}
		}

		if var result ?= this.toStatementFragments(fragments, mode) {
			result.afterwards = @afterwards

			return result
		}
		else {
			for var afterward in @afterwards {
				afterward.toAfterwardFragments(fragments, mode)
			}
		}
	} # }}}
}

include {
	'../statement/block'
	'../statement/break'
	'../statement/class/index'
	'../statement/continue'
	'../statement/disclose'
	'../statement/do-until'
	'../statement/do-while'
	'../statement/enum'
	'../statement/bitmask'
	'../statement/export'
	'../statement/expression'
	'../statement/fallthrough'
	'../statement/for-from'
	'../statement/for-in'
	'../statement/for-of'
	'../statement/for-range'
	'../statement/function'
	'../statement/if'
	'../statement/implement/index'
	'../statement/import'
	'../statement/dependency'
	'../statement/include'
	'../statement/match'
	'../statement/namespace'
	'../statement/pass'
	'../statement/repeat'
	'../statement/return'
	'../statement/set'
	'../statement/throw'
	'../statement/try'
	'../statement/type'
	'../statement/unless'
	'../statement/until'
	'../statement/variable'
	'../statement/while'
	'../statement/with'
}
