class UnaryOperatorExpression extends Expression {
	private {
		@argument
	}
	analyse() { # {{{
		@argument = $compile.expression(@data.argument, this)
		@argument.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@argument.prepare(target, targetMode)

		if @argument.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}
	} # }}}
	translate() { # {{{
		@argument.translate()
	} # }}}
	argument() => @argument
	hasExceptions() => false
	inferTypes(inferables) => @argument.inferTypes(inferables)
	isUsingVariable(name) => @argument.isUsingVariable(name)
	listAssignments(array: Array) => @argument.listAssignments(array)
}

abstract class NumericUnaryOperatorExpression extends UnaryOperatorExpression {
	private late {
		@isEnum: Boolean		= false
		@isNative: Boolean		= false
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		if @isAcceptingEnum() && @argument.type().isEnum() {
			@isEnum = true

			@type = @argument.type()
		}
		else {
			if @argument.type().isNumber() {
				if @argument.type().isNullable() {
					TypeException.throwNotNullableOperand(@argument, this.operator(), this)
				}

				@isNative = true
			}
			else if !@argument.type().canBeNumber() {
				TypeException.throwInvalidOperand(@argument, this.operator(), this)
			}

			@type = @scope.reference('Number')
		}
	} # }}}
	isAcceptingEnum() => false
	abstract operator(): Operator
	abstract runtime(): String
	abstract symbol(): String
	toFragments(fragments, mode) { # {{{
		if @isEnum {
			fragments.code(@symbol(), @data.operator).wrap(@argument)
		}
		else if @isNative {
			fragments.code(@symbol(), @data.operator).wrap(@argument)
		}
		else {
			fragments.code($runtime.operator(this), `.\(@runtime())(`).compile(@argument).code(')')
		}
	} # }}}
	toQuote() => `\(@symbol())\(@argument.toQuote())`
	type() => @type
}

class UnaryOperatorImplicit extends Expression {
	private late {
		@property: String
		@type: Type
	}
	override analyse() { # {{{
		@property = @data.argument.name
	} # }}}
	override prepare(target, targetMode) { # {{{
		var late type: Type

		match @parent {
			is AssignmentOperatorAddition | AssignmentOperatorSubtraction | BinaryOperatorAddition | BinaryOperatorSubtraction | PolyadicOperatorAddition | PolyadicOperatorSubtraction {
				type = target
			}
			is AssignmentOperatorEquals | BinaryOperatorNullCoalescing {
				type = target
			}
			is BinaryOperatorMatch {
				type = @parent.subject().type()
			}
			is CallExpression {
				var index = @parent.arguments().indexOf(this)
				var types = []

				for var function of @parent.assessment().functions {
					if function.min() == function.max() > index {
						types.push(function.parameter(index).getVariableType())
					}
					else {
						throw NotSupportedException.new()
					}
				}

				type = Type.union(@scope, ...types)
			}
			is ClassVariableDeclaration {
				type = @parent.type().type()
			}
			is ComparisonExpression {
				var operands = @parent.operands()
				var index = operands.indexOf(this)
				var operand = operands[index - 1]

				type = operand.type()
			}
			is MatchConditionValue {
				type = @parent.parent().getValueType()
			}
			is NamedArgument {
				var name = @parent.name()
				var types = []

				for var function of @parent.parent().assessment().functions {
					for var parameter in function.parameters() {
						if parameter.getExternalName() == name {
							types.push(parameter.getVariableType())
						}
					}
				}

				type = Type.union(@scope, ...types)
			}
			is ClassConstructorDeclaration | ClassMethodDeclaration | FunctionDeclarator | StructFunction | TupleFunction | VariableDeclaration {
				type = target
			}
			else {
				echo(@parent)
				throw NotImplementedException.new()
			}
		}

		if type.isAny() || type.isUnion() {
			ReferenceException.throwNotDefinedProperty(@property, this)
		}
		else if type.isEnum() {
			if !type.discard().hasVariable(@property) {
				ReferenceException.throwNotDefinedEnumElement(@property, type.name(), this)
			}

			@type = type
		}
		else if var property ?= type.getProperty(@property) {
			@type = property.discardVariable()
		}
		else {
			ReferenceException.throwNotDefinedProperty(@property, this)
		}
	} # }}}
	override translate()
	property() => @property
	toFragments(fragments, mode) { # {{{
		fragments.compile(@type).code($dot).compile(@property)
	} # }}}
	type() => @type
}

class UnaryOperatorNegation extends UnaryOperatorExpression {
	private late {
		@native: Boolean		= false
		@operand: OperandType	= OperandType.Any
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		var mut boolean = true
		var mut number = true
		var mut native = true

		if !target.isVoid() {
			boolean = target.canBeBoolean()
			number = target.canBeNumber()
		}

		var type = @argument.type()

		if type.isBoolean() {
			number = false
		}
		else if type.isNumber() {
			boolean = false
		}
		else if type.canBeBoolean() {
			if !type.canBeNumber() {
				number = false
			}

			native = false
		}
		else if type.canBeNumber() {
			boolean = false
			native = false
		}
		else {
			TypeException.throwInvalidOperand(@argument, Operator.Negation, this)
		}

		if !boolean && !number {
			if !target.isVoid() {
				TypeException.throwUnexpectedExpression(this, target, this)
			}
			else {
				TypeException.throwInvalidOperation(this, Operator.Negation, this)
			}
		}

		if boolean {
			if number {
				@type = UnionType.new(@scope, [@scope.reference('Boolean'), @scope.reference('Number')])

				if type.isNullable() {
					@type = @type.setNullable(true)
				}
			}
			else {
				@type = @scope.reference('Boolean')
				@operand = OperandType.Boolean
				@native = true
			}
		}
		else if number {
			@type = @scope.reference('Number')
			@operand = OperandType.Number
			@native = native

			if type.isNullable() {
				@type = @type.setNullable(true)
			}
		}
	} # }}}
	inferWhenFalseTypes(inferables) => @argument.inferWhenTrueTypes(inferables)
	inferWhenTrueTypes(inferables) => @argument.inferWhenFalseTypes(inferables)
	toFragments(fragments, mode) { # {{{
		if @native {
			if @operand == OperandType.Boolean {
				fragments.code('!', @data.operator).wrapCondition(@argument)
			}
			else {
				fragments.code('~', @data.operator).compile(@argument)
			}
		}
		else {
			fragments.code(`\($runtime.operator(this))`)

			if @operand == OperandType.Number {
				fragments.code('.negationNum(')
			}
			else {
				fragments.code('.negation(')
			}

			fragments.compile(@argument).code(')')
		}
	} # }}}
	type(): @type
}

class UnaryOperatorNegative extends NumericUnaryOperatorExpression {
	operator() => Operator.Negative
	runtime() => 'negative'
	symbol() => '-'
}

class UnaryOperatorSpread extends UnaryOperatorExpression {
	private late {
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		if @parent is ArrayExpression {
			var targetArray = Type.arrayOf(target, @scope)

			super(targetArray, targetMode)

			var type = @argument.type()

			if type.isArray() {
				@type = type.flagSpread()
			}
			else {
				@type = targetArray.flagSpread()
			}
		}
		else {
			super(target, targetMode)

			var type = @argument.type()

			if type.isArray() {
				@type = type.flagSpread()
			}
			else if type.isAny() {
				@type = @scope.reference('Array').flagSpread()
			}
			else {
				TypeException.throwInvalidSpread(this)
			}
		}
	} # }}}
	isExpectingType() => true
	toFragments(fragments, mode) { # {{{
		if @options.format.spreads == 'es5' {
			throw NotSupportedException.new(this)
		}

		fragments
			.code('...', @data.operator)
			.wrap(@argument)
	} # }}}
	toTypeQuote() { # {{{
		var type = @type.parameter(0)

		return `...\(type.toQuote())`
	} # }}}
	type() => @type
}
