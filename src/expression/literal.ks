class Literal extends Expression {
	private {
		@value
	}
	constructor(@value, @parent) { # {{{
		super(false, parent)
	} # }}}
	constructor(data, parent, scope, @value) { # {{{
		super(data, parent, scope)
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	hasExceptions() => false
	isComposite() => false
	listAssignments(array: Array<String>) => array
	override listNonLocalVariables(scope, variables) => variables
	toFragments(fragments, mode) { # {{{
		if @data {
			fragments.code(@value, @data)
		}
		else {
			fragments.code(@value)
		}
	} # }}}
	toQuote() => @value
	validateType(type: ReferenceType) { # {{{
		if !@type().isAssignableToVariable(type, false) {
			TypeException.throwInvalidAssignement(type, @type(), this)
		}
	} # }}}
	value() => @value
}

class IdentifierLiteral extends Literal {
	private late {
		@assignable: Boolean			= false
		@assignment: AssignmentType		= AssignmentType::Neither
		@declaredType: Type
		@isMacro: Boolean				= false
		@isVariable: Boolean			= false
		@line: Number
		@realType: Type
	}
	constructor(data, parent, scope = parent.scope()) { # {{{
		super(data, parent, scope, data.name)
	} # }}}
	analyse() { # {{{
		if @assignment == AssignmentType::Neither {
			if @scope.hasVariable(@value) {
				@isVariable = true
				@line = @scope.line()

				if @value == 'Object' {
					@module().flag('Object')
				}
			}
			else if @scope.hasMacro(@value) {
				@isMacro = true
			}
			else if var name ?= $runtime.getVariable(@value, @parent) {
				@value = name
				@realType = @declaredType = Type.Any
			}
			else if @options.rules.ignoreError {
				@realType = @declaredType = Type.Any
			}
			else {
				ReferenceException.throwNotDefined(@value, this)
			}
		}
		else {
			@isVariable = true
			@line = @scope.line()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @isVariable {
			var variable = @scope.getVariable(@value, @line)

			if @assignable {
				if variable.isImmutable() {
					if variable.isLateInit() {
						if variable.isInitialized() {
							ReferenceException.throwImmutable(@value, this)
						}
					}
					else {
						ReferenceException.throwImmutable(@value, this)
					}
				}
			}

			if @scope.hasDeclaredVariable(@value) && !@scope.hasDefinedVariable(@value, @line) && !variable.isPredefined() {
				@scope.renameNext(@value, @line)
			}

			if @assignment == AssignmentType::Neither && variable.isLateInit() && !variable.isInitialized() {
				SyntaxException.throwNotInitializedVariable(@value, this)
			}

			@declaredType = variable.getDeclaredType()
			@realType = variable.getRealType()
		}

		unless targetMode == TargetMode::Permissive || target.isVoid() || !@realType.isExplicit() || !target.isExplicit() || @realType.isSubsetOf(target, MatchingMode::Signature) {
			TypeException.throwInvalidIdentifierType(@value, @realType, target, this)
		}
	} # }}}
	export(recipient) { # {{{
		recipient.export(@value, this)
	} # }}}
	flagAssignable() { # {{{
		@assignable = true
	} # }}}
	getVariableDeclaration(class) { # {{{
		return class.getInstanceVariable(@value)
	} # }}}
	getDeclaredType() => @declaredType
	getUnpreparedType() { # {{{
		if @isVariable {
			return @scope.getVariable(@value, @line).getRealType()
		}
		else {
			return @realType
		}
	} # }}}
	initializeVariables(type: Type, node: Expression) { # {{{
		if @isVariable {
			var variable = @scope.getVariable(@value, @line)

			if variable.isLateInit() {
				node.initializeVariable(VariableBrief(
					name: @value
					type
					immutable: true
					lateInit: true
				))
			}
		}
	} # }}}
	isAssignable() => true
	isDeclarable() => true
	isDeclararingVariable(name: String) => @value == name
	isExpectingType() { # {{{
		if @isVariable {
			var variable = @scope.getVariable(@value, @line)

			return variable.isDefinitive()
		}
		else {
			return false
		}
	} # }}}
	isMacro() => @isMacro
	isRedeclared() => @scope.isRedeclaredVariable(@value)
	isRenamed() => @scope.isRenamedVariable(@value)
	isInferable() => true
	override isUsingNonLocalVariables(scope) { # {{{
		if @isVariable {
			var variable = @scope.getVariable(@value, @line)

			if @value != 'this' && !variable.isPredefined() && !scope.hasDeclaredVariable(@value) {
				return true
			}
		}

		return false
	} # }}}
	isUsingVariable(name) => @value == name
	listAssignments(array: Array<String>) { # {{{
		array.push(@value)

		return array
	} # }}}
	override listLocalVariables(scope, variables) { # {{{
		if @isVariable {
			var variable = @scope.getVariable(@value, @line)

			if @value != 'this' && !variable.isPredefined() && scope.hasDeclaredVariable(@value) {
				variables.pushUniq(variable)
			}
		}

		return variables
	} # }}}
	override listNonLocalVariables(scope, variables) { # {{{
		if @isVariable {
			var variable = @scope.getVariable(@value, @line)

			if @value != 'this' && !variable.isModule() && !scope.hasDeclaredVariable(@value) {
				variables.pushUniq(variable)
			}
		}

		return variables
	} # }}}
	name() => @value
	path() => @value
	setAssignment(@assignment)
	toAssignmentFragments(fragments, value) { # {{{
		fragments.compile(this).code($equals).compile(value)
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @isVariable {
			fragments.compile(@scope.getVariable(@value, @line))
		}
		else {
			fragments.code(@value, @data)
		}
	} # }}}
	type() => @realType
	type(type: Type, scope: Scope, node) { # {{{
		if @isVariable {
			@realType = scope.replaceVariable(@value, type, node).getRealType()
		}
	} # }}}
	variable() => @scope.getVariable(@value, @line)
	walk(fn) { # {{{
		if @isVariable {
			fn(@value, @realType)
		}
		else {
			throw new NotSupportedException()
		}
	} # }}}
}

class NumberLiteral extends Literal {
	private {
		@type: Type
	}
	constructor(data, parent, scope = parent.scope()) { # {{{
		super(data, parent, scope, data.value)

		@type = @scope.reference('Number')
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless targetMode == TargetMode::Permissive || target.isVoid() || !target.isExplicit() || @type.isSubsetOf(target, MatchingMode::Signature) {
			TypeException.throwInvalidLiteralType(`"\(@value)"`, @type, target, this)
		}
	} # }}}
	getUnpreparedType(): @type
	type(): @type
}

class StringLiteral extends Literal {
	private {
		@type: Type
	}
	constructor(data, parent, scope = parent.scope()) { # {{{
		super(data, parent, scope, $quote(data.value))

		@type = @scope.reference('String')
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless targetMode == TargetMode::Permissive || target.isVoid() || !target.isExplicit() || @type.isSubsetOf(target, MatchingMode::Signature) {
			TypeException.throwInvalidLiteralType(@value, @type, target, this)
		}
	} # }}}
	getUnpreparedType(): @type
	isNotEmpty() => @value.length > 0
	type(): @type
}
