class Literal extends Expression {
	private late {
		@type: Type
		@value
	}
	constructor(@value, @parent) { # {{{
		super(false, parent)
	} # }}}
	constructor(data, parent, scope, @value, @type = AnyType.NullableUnexplicit) { # {{{
		super(data, parent, scope)
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	hasExceptions() => false
	isComposite() => false
	listAssignments(array: Array) => array
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
	type() => @type
	validateType(type: ReferenceType) { # {{{
		if !@type().isAssignableToVariable(type, false) {
			TypeException.throwInvalidAssignment(type, @type(), this)
		}
	} # }}}
	value() => @value
}

class IdentifierLiteral extends Literal {
	private late {
		@assignable: Boolean			= false
		@assignment: AssignmentType		= AssignmentType.Neither
		@declaredType: Type
		@isMacro: Boolean				= false
		@isVariable: Boolean			= false
		@line: Number
		@path: String
	}
	constructor(data, parent, scope = parent.scope()) { # {{{
		super(data, parent, scope, data.name)

		@path = @value
	} # }}}
	analyse() { # {{{
		if @assignment == AssignmentType.Neither {
			if @scope.hasVariable(@value) {
				@isVariable = true
				@line = @scope.line()

				if @value == 'Object' {
					@module().flag('Object')
				}

				if var variable ?= @scope.getVariable(@value) {
					var type = variable.getDeclaredType()

					if type.isView() && !type.isReference() {
						@path = type.discard().name()
					}
					else if type is NamedType && type.type() is AliasType && !(@parent is ExportDeclaration || (@parent is MemberExpression && @parent.parent() is MatchConditionValue)) {
						ReferenceException.throwAliasTypeVariable(type.name(), this)
					}
					// TODO
					// if @parent.isAccessibleAliasType(this) {
					// 	ReferenceException.throwAliasTypeVariable(type.name(), this)
					// }
				}
			}
			else if @scope.hasMacro(@value) {
				@isMacro = true
			}
			else if var name ?= $runtime.getVariable(@value, @parent) {
				@path = @value = name
				@type = @declaredType = Type.Any
			}
			else if @options.rules.ignoreError {
				@type = @declaredType = Type.Any
			}
			else {
				ReferenceException.throwNotDefined(@value, this)
			}
		}
		else {
			if @value == 'this' {
				SyntaxException.throwReservedThisVariable(this)
			}

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

			if @assignment == AssignmentType.Neither && variable.isLateInit() && !variable.isInitialized() {
				SyntaxException.throwNotInitializedVariable(@value, this)
			}

			@declaredType = variable.getDeclaredType()

			var type = variable.getRealType()

			if variable.isPredefined() && type.isBoolean() {
				@type = ValueType.new(@value, type, @value, @scope)
			}
			else {
				@type = type
			}
		}

		unless targetMode == TargetMode.Permissive || target.isVoid() || !@type.isExplicit() || !target.isExplicit() || @type.isSubsetOf(target, MatchingMode.Signature) {
			TypeException.throwInvalidIdentifierType(@value, @type.discardValue(), target, this)
		}
	} # }}}
	caller() => 'null'
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
	getSecureName() => @isVariable ? @variable().getSecureName() : @value
	getUnpreparedType() { # {{{
		if @isVariable {
			return @scope.getVariable(@value, @line).getRealType()
		}
		else {
			return @type
		}
	} # }}}
	initializeVariables(type: Type, node: Expression) { # {{{
		if @isVariable {
			var variable = @scope.getVariable(@value, @line)

			if variable.isLateInit() {
				node.initializeVariable(VariableBrief.new(
					name: @value
					type: type.unspecify()
					immutable: true
					lateInit: true
				))
			}
			else {
				@scope.replaceVariable(@value, type, this)
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
	isVariable() => @isVariable
	listAssignments(array: Array, immutable: Boolean? = null) { # {{{
		array.push({ name: @value, immutable })

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
			fragments.compile(@scope.getVariable(@path, @line))
		}
		else {
			fragments.code(@path, @data)
		}
	} # }}}
	type(type: Type, scope: Scope, node) { # {{{
		if @isVariable {
			@type = scope.replaceVariable(@value, type, node).getRealType()
		}
	} # }}}
	unspecify() { # {{{
		return unless @isVariable

		if @type.isSpecific() {
			@scope.replaceVariable(@value, @type.unspecify(), this)

			var variable = @scope.getVariable(@value)

			@type = variable.getRealType()
		}
	} # }}}
	variable() => @scope.getVariable(@value, @line)
	walk(fn) { # {{{
		if @isVariable {
			fn(@value, @type)
		}
		else {
			throw NotSupportedException.new()
		}
	} # }}}
}

class NumberLiteral extends Literal {
	constructor(data, parent, scope = parent.scope()) { # {{{
		super(data, parent, scope, data.value)

		@type = @scope.reference('Number')
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless targetMode == TargetMode.Permissive || target.isVoid() || !target.isExplicit() || @type.isSubsetOf(target, MatchingMode.Signature) {
			TypeException.throwInvalidLiteralType(`"\(@value)"`, @type, target, this)
		}
	} # }}}
	getUnpreparedType(): valueof @type
	override path() => `\(@value)`
}

class StringLiteral extends Literal {
	constructor(data, parent, scope = parent.scope()) { # {{{
		super(data, parent, scope, $quote(data.value))

		@type = @scope.reference('String')
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless targetMode == TargetMode.Permissive || target.isVoid() || !target.isExplicit() || @type.isSubsetOf(target, MatchingMode.Signature) {
			TypeException.throwInvalidLiteralType(@value, @type, target, this)
		}
	} # }}}
	getUnpreparedType(): valueof @type
	isNotEmpty() => @value.length > 0
	override path() => @value
}
