abstract class AssignmentOperatorExpression extends Expression {
	private late {
		@await: Boolean				= false
		@bindingScope: Scope
		@left						= null
		@right						= null
		@type: Type
	}
	analyse() { # {{{
		@left = $compile.expression(@data.left, this)

		if !this.isAssigningBinding() && (@left is ArrayBinding || @left is ObjectBinding) {
			SyntaxException.throwUnsupportedDestructuringAssignment(this)
		}

		if this.isDeclararing() {
			@left.setAssignment(AssignmentType::Expression)
		}

		@left.analyse()

		@bindingScope = this.newScope(@scope, ScopeType::Hollow)

		@right = $compile.expression(@data.right, this, @bindingScope)

		@right.analyse()

		@await = @right.isAwait()

		if this.isDeclararing() {
			this.defineVariables(@left)
		}
	} # }}}
	override prepare(target) { # {{{
		@left.flagAssignable()

		@left.prepare(target)

		// if var variable = @left.variable() {
		// 	if variable.isInitialized() {
		// 		@right.setExpectedType(variable.getRealType())
		// 	}
		// 	else {
		// 		@right.setExpectedType(variable.getDeclaredType())
		// 	}
		// }
		// else {
		// 	@right.setExpectedType(@left.type())
		// }
		if var variable = @left.variable() {
			if variable.isInitialized() {
				@type = variable.getRealType()
			}
			else {
				@type = variable.getDeclaredType()
			}
		}
		else {
			@type = @left.type()
		}

		if target? {
			if target.isAssignableToVariable(@type, true, true, false) {
				@type = target
			}
			else {
				TypeException.throwUnexpectedExpression(this, target, this)
			}
		}

		@right.prepare(@type)

		if @right.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@right, this)
		}
	} # }}}
	translate() { # {{{
		@left.translate()
		@right.translate()
	} # }}}
	defineVariables(left) { # {{{
		var statement = @statement()

		statement.defineVariables(left, @scope, @leftMost, @leftMost == this)
	} # }}}
	isAssigningBinding() => false
	isAwait() => @await
	isAwaiting() => @right.isAwaiting()
	isComputed() => true
	isDeclararing() => false
	isDeclararingVariable(name: String) => this.isDeclararing() && @left.isDeclararingVariable(name)
	isExpectingType() => @left.isExpectingType()
	isImmutable(variable) => variable.isImmutable()
	isNullable() => @right.isNullable()
	isUsingVariable(name) => @left.isUsingVariable(name) || @right.isUsingVariable(name)
	isUsingInstanceVariable(name) => @left.isUsingInstanceVariable(name) || @right.isUsingInstanceVariable(name)
	isUsingStaticVariable(class, varname) => @left.isUsingStaticVariable(class, varname) || @right.isUsingStaticVariable(class, varname)
	listAssignments(array: Array<String>) => @left.listAssignments(@right.listAssignments(array))
	setAssignment(assignment)
	toNullableFragments(fragments) { # {{{
		fragments.compileNullable(@right)
	} # }}}
	variable() => @left.variable()
}

abstract class NumericAssignmentOperatorExpression extends AssignmentOperatorExpression {
	private late {
		@adjusted: Boolean			= false
		@enum: Boolean				= false
		@expectingEnum: Boolean		= true
		@native: Boolean			= false
	}
	override prepare(target) { # {{{
		super(target)

		if target? && !target.canBeEnum() {
			@expectingEnum = false
		}

		if @isAcceptingEnum() && @left.type().isEnum() && @right.type().isEnum() && @left.type().name() == @right.type().name() {
			@enum = true

			@type = @left.type()

			if @expectingEnum {
				@type = @left.type()
			}
			else {
				@type = @left.type().discard().type()
			}

			@left.unflagExpectingEnum()
			@right.unflagExpectingEnum()

			if @right is BinaryOperatorExpression | PolyadicOperatorExpression {
				var mut leftMost = @right

				while leftMost.left() is BinaryOperatorExpression | PolyadicOperatorExpression {
					leftMost = leftMost.left()
				}

				var newLeft = new BinaryOperatorSubtraction(@data, leftMost, @scope)

				newLeft.setOperands(@left, leftMost.left(), enum: true, expectingEnum: false)

				leftMost.left(newLeft)

				@adjusted = true
			}
		}
		else {
			if @left.type().isNumber() && @right.type().isNumber() {
				@native = true
			}
			else if @left.type().canBeNumber() {
				unless @right.type().canBeNumber() {
					TypeException.throwInvalidOperand(@right, this.operator(), this)
				}
			}
			else {
				TypeException.throwInvalidOperand(@left, this.operator(), this)
			}

			if @left.type().isNullable() || @right.type().isNullable() {
				@type = @scope.reference('Number').setNullable(true)

				@native = false
			}
			else {
				@type = @scope.reference('Number')
			}

			if @left is IdentifierLiteral {
				@left.type(@type, @scope, this)
			}
		}
	} # }}}
	isAcceptingEnum() => false
	abstract runtime(): String
	abstract symbol(): String
	toFragments(fragments, mode) { # {{{
		if @adjusted {
			if @enum && @expectingEnum {
				fragments.compile(@left).code($equals, @type.name(), '(').compile(@right).code(')')
			}
			else {
				fragments.compile(@left).code($equals).compile(@right)
			}
		}
		else if @enum {
			this.toEnumFragments(fragments)
		}
		else if @native {
			this.toNativeFragments(fragments)
		}
		else {
			fragments
				.compile(@left)
				.code(' = ')
				.code($runtime.operator(this), `.\(this.runtime())(`)
				.compile(@left)
				.code($comma)

			@right.toOperandFragments(fragments, this.operator(), OperandType::Number)

			fragments.code(')')
		}
	} # }}}
	toEnumFragments(fragments)
	toNativeFragments(fragments) { # {{{
		fragments.compile(@left).code($space).code(this.symbol(), @data.operator).code($space).compile(@right)
	} # }}}
	toQuote() => `\(@left.toQuote()) \(this.symbol()) \(@right.toQuote())`
	type() => @type
}

abstract class LogicalAssignmentOperatorExpression extends AssignmentOperatorExpression {
	private late {
		@native: Boolean		= false
		@operand: OperandType	= OperandType::Any
	}
	override prepare(target) { # {{{
		// if this.isAcceptingEnum() && @left.type().isEnum() && @right.type().isEnum() && @left.type().name() == @right.type().name() {
		// 	@enum = true

		// 	@type = @left.type()
		// }
		// else {
		// 	if @left.type().isNumber() && @right.type().isNumber() {
		// 		@native = true
		// 	}
		// 	else if @left.type().canBeNumber() {
		// 		unless @right.type().canBeNumber() {
		// 			TypeException.throwInvalidOperand(@right, this.operator(), this)
		// 		}
		// 	}
		// 	else {
		// 		TypeException.throwInvalidOperand(@left, this.operator(), this)
		// 	}

		// 	if @left.type().isNullable() || @right.type().isNullable() {
		// 		@type = @scope.reference('Number').setNullable(true)

		// 		@native = false
		// 	}
		// 	else {
		// 		@type = @scope.reference('Number')
		// 	}

		// 	if @left is IdentifierLiteral {
		// 		@left.type(@type, @scope, this)
		// 	}
		// }
		super(target)

		var mut nullable = false
		var mut boolean = true
		var mut number = true
		var mut native = true

		if @type.isBoolean() {
			number = false
		}
		else if @type.isNumber() {
			if @type.isNullable() {
				nullable = true
				native = false
			}

			boolean = false
		}
		else if @type.isNull() {
			nullable = true
		}
		else if @type.canBeBoolean() {
			if @type.isNullable() {
				nullable = true
			}

			if !@type.canBeNumber() {
				number = false
			}
			else if !boolean {
				native = false
			}
		}
		else if @type.canBeNumber() {
			if @type.isNullable() {
				nullable = true
			}

			boolean = false
			native = false
		}
		else {
			if target? {
				TypeException.throwUnexpectedExpression(this, target, this)
			}
			else {
				TypeException.throwInvalidOperation(this, @operator(), this)
			}
		}

		if !boolean && !number {
			if target? {
				TypeException.throwUnexpectedExpression(this, target, this)
			}
			else {
				TypeException.throwInvalidOperation(this, @operator(), this)
			}
		}

		if boolean {
			if number {
				@type = new UnionType(@scope, [@scope.reference('Boolean'), @scope.reference('Number')])

				if nullable {
					@type = @type.setNullable(true)
				}
			}
			else {
				@type = @scope.reference('Boolean')
				@operand = OperandType::Boolean
				@native = true
			}
		}
		else if number {
			@type = @scope.reference('Number')
			@operand = OperandType::Number
			@native = native

			if nullable {
				@type = @type.setNullable(true)
			}
		}
	} # }}}
	abstract native(): String
	abstract operator(): Operator
	abstract runtime(): String
	abstract symbol(): String
	toFragments(fragments, mode) { # {{{
		if @native {
			@toNativeFragments(fragments)
		}
		else {
			var late operator
			if @operand == OperandType::Number {
				operator = `\(@runtime())Num`
			}
			else {
				operator = @runtime()
			}

			fragments
				.compile(@left)
				.code(' = ')
				.code($runtime.operator(this), `.\(operator)(`)
				.compile(@left)
				.code($comma)
				.compile(@right)
				.code(')')
		}
	} # }}}
	toNativeFragments(fragments) { # {{{
		if @operand == OperandType::Boolean {
			fragments.compile(@left).code(' = ').compile(@left).code(` \(@native()) `).compile(@right)
		}
		else {
			fragments.compile(@left).code($space).code(@native(), @data.operator).code($space).compile(@right)
		}
	} # }}}
	toQuote() => `\(@left.toQuote()) \(@symbol()) \(@right.toQuote())`
	type() => @type
}

class AssignmentOperatorAddition extends AssignmentOperatorExpression {
	private late {
		@adjusted: Boolean			= false
		@enum: Boolean				= false
		@expectingEnum: Boolean		= true
		@native: Boolean			= false
		@number: Boolean			= false
		@string: Boolean			= false
	}
	override prepare(target) { # {{{
		super(target)

		if target? && !target.canBeEnum() {
			@expectingEnum = false
		}

		if @left.type().isEnum() && @right.type().isEnum() && @left.type().name() == @right.type().name() {
			@enum = true
			@number = @left.type().discard().isFlags()

			if @expectingEnum {
				@type = @left.type()
			}
			else {
				@type = @left.type().discard().type()
			}

			@left.unflagExpectingEnum()
			@right.unflagExpectingEnum()

			if @right is BinaryOperatorExpression | PolyadicOperatorExpression {
				var mut leftMost = @right

				while leftMost.left() is BinaryOperatorExpression | PolyadicOperatorExpression {
					leftMost = leftMost.left()
				}

				var newLeft = new BinaryOperatorAddition(@data, leftMost, @scope)

				newLeft.setOperands(@left, leftMost.left(), enum: true, number: @number, expectingEnum: false)

				leftMost.left(newLeft)

				@adjusted = true
			}
		}
		else {
			if @left.type().isString() || @right.type().isString() {
				@string = true
				@native = true
			}
			else if @left.type().isNumber() && @right.type().isNumber() {
				@number = true
				@native = true
			}
			else if (@left.type().canBeString(false) && !@left.type().canBeNumber(false)) || (@right.type().canBeString(false) && !@right.type().canBeNumber(false)) {
				@string = true
			}
			else if @left.type().isAny() || @right.type().isAny() {
			}
			else if @left.type().canBeNumber() {
				if !@left.type().canBeString(false) {
					if @right.type().canBeNumber() {
						if !@right.type().canBeString(false) {
							@number = true
						}
					}
					else {
						TypeException.throwInvalidOperand(@right, Operator::Addition, this)
					}
				}
			}
			else {
				TypeException.throwInvalidOperand(@left, Operator::Addition, this)
			}

			var nullable = @left.type().isNullable() || @right.type().isNullable()
			if nullable {
				@native = false
			}

			if @number {
				@type = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')
			}
			else if @string {
				@type = @scope.reference('String')
			}
			else {
				var numberType = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')

				@type = new UnionType(@scope, [numberType, @scope.reference('String')], false)
			}
		}

		if @left is IdentifierLiteral {
			@left.type(@type, @scope, this)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @adjusted {
			if @enum && @expectingEnum {
				fragments.compile(@left).code($equals, @type.name(), '(').compile(@right).code(')')
			}
			else {
				fragments.compile(@left).code($equals).compile(@right)
			}
		}
		else if @enum {
			fragments.compile(@left).code($equals, @type.name(), '(').compile(@left)

			if @number {
				fragments.code(' | ')
			}
			else {
				fragments.code(' + ')
			}

			@right.toOperandFragments(fragments, Operator::Addition, OperandType::Enum)

			fragments.code(')')
		}
		else if @native {
			fragments.compile(@left).code(' += ').compile(@right)
		}
		else {
			fragments.compile(@left).code($equals)

			var mut type
			if @number {
				fragments.code($runtime.operator(this), '.addition(')

				type = OperandType::Number
			}
			else if @string {
				fragments.code($runtime.helper(this), '.concatString(')

				type = OperandType::String
			}
			else {
				fragments.code($runtime.operator(this), '.addOrConcat(')

				type = OperandType::Any
			}

			fragments.compile(@left).code($comma)

			@right.toOperandFragments(fragments, Operator::Addition, type)

			fragments.code(')')
		}
	} # }}}
	type() => @type
}

class AssignmentOperatorAnd extends LogicalAssignmentOperatorExpression {
	isAcceptingEnum() => true
	native() => @operand == OperandType::Boolean ? '&&' : '&='
	operator() => Operator::And
	runtime() => 'and'
	symbol() => '&&='
	toEnumFragments(fragments) { # {{{
		// fragments.compile(@left).code($equals, @type.name(), '(').compile(@left).code(' & ').compile(@right).code(')')
	} # }}}
}

class AssignmentOperatorDivision extends NumericAssignmentOperatorExpression {
	operator() => Operator::Division
	runtime() => 'division'
	symbol() => '/='
}

class AssignmentOperatorEquality extends AssignmentOperatorExpression {
	private late {
		@condition: Boolean		= false
		@ignorable: Boolean		= false
		@lateinit: Boolean		= false
	}
	analyse() { # {{{
		@condition = @statement() is IfStatement

		super()
	} # }}}
	override prepare(target) { # {{{
		super()

		if @condition && @lateinit {
			@statement.initializeLateVariable(@left.name(), @right.type(), true)
		}
		else {
			@left.initializeVariables(@right.type(), this)
		}

		@type = @left.getDeclaredType()

		if this.isInDestructor() {
			@type = NullType.Explicit
		}
		else {
			unless @right.type().matchContentOf(@type) || (@left is ObjectBinding && @right.type().isDictionary()) {
				TypeException.throwInvalidAssignement(@left, @type, @right.type(), this)
			}

			if @left.isInferable() && @right.type().isMorePreciseThan(@type) {
				@type = @right.type()
			}
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		@right.acquireReusable(@left.isSplitAssignment())
	} # }}}
	defineVariables(left) { # {{{
		if @condition {
			var names = []

			for var name in left.listAssignments([]) {
				if var variable = @scope.getVariable(name) {
					if variable.isLateInit() {
						throw new NotImplementedException(this)
					}
					else if variable.isImmutable() {
						ReferenceException.throwImmutable(name, this)
					}
				}
				else {
					names.push(name)
				}
			}

			if names.length > 0 {
				@statement.defineVariables(left, names, @scope, @leftMost, @leftMost == this)
			}
		}
		else {
			@statement.defineVariables(left, @scope, @leftMost, @leftMost == this)
		}
	} # }}}
	flagAssignable()
	hasExceptions() => @right.isAwaiting() && @right.hasExceptions()
	inferTypes(inferables) { # {{{
		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @type
			}
		}

		return inferables
	} # }}}
	initializeVariable(variable: VariableBrief) { # {{{
		@parent.initializeVariable(variable, this)
	} # }}}
	initializeVariable(variable: VariableBrief, expression: Expression) { # {{{
		@parent.initializeVariable(variable, expression)
	} # }}}
	initializeVariables(type: Type, node: Expression)
	isAssigningBinding() => true
	isDeclarable() => @left.isDeclarable()
	isDeclararing() => true
	isIgnorable() => @ignorable
	private isInDestructor() { # {{{
		if @parent is not ExpressionStatement {
			return false
		}

		var dyn parent = @parent

		while parent? {
			parent = parent.parent()

			if parent is ClassDestructorDeclaration {
				return true
			}
		}

		return false
	} # }}}
	releaseReusable() { # {{{
		@right.releaseReusable()
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @right.isAwaiting() {
			return @right.toFragments(fragments, mode)
		}
		else if @left.isUsingSetter() {
			@left.toSetterFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).compile(@right)
		}
	} # }}}
	toAssignmentFragments(fragments) { # {{{
		if @left.toAssignmentFragments? {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).compile(@right)
		}
	} # }}}
	toBooleanFragments(fragments, mode, junction) { # {{{
		fragments.compile(@left).code($equals).wrap(@right)
	} # }}}
	toQuote() => `\(@left.toQuote()) = \(@right.toQuote())`
	type() => @type
}

class AssignmentOperatorExistential extends AssignmentOperatorExpression {
	private {
		@condition: Boolean		= false
		@lateinit: Boolean		= false
	}
	analyse() { # {{{
		@condition = @statement() is IfStatement

		super()
	} # }}}
	override prepare(target) { # {{{
		super()

		@right.acquireReusable(true)
		@right.releaseReusable()

		if @left is IdentifierLiteral {
			var type = @right.type().setNullable(false)

			if @condition {
				if @lateinit {
					@statement.initializeLateVariable(@left.name(), type, true)
				}
				else {
					@left.type(type, @scope, this)
				}
			}
			else {
				@left.type(type, @scope, this)
			}
		}
	} # }}}
	defineVariables(left) { # {{{
		if @condition {
			var names = []

			for var name in left.listAssignments([]) {
				if var variable = @scope.getVariable(name) {
					if variable.isLateInit() {
						@statement.addInitializableVariable(variable, true, this)
						@lateinit = true
					}
					else if variable.isImmutable() {
						ReferenceException.throwImmutable(name, this)
					}
				}
				else {
					names.push(name)
				}
			}

			if names.length > 0 {
				@statement.defineVariables(left, names, @scope, @leftMost, @leftMost == this)
			}
		}
		else {
			@statement.defineVariables(left, @scope, @leftMost, @leftMost == this)
		}
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @right.type().setNullable(false)
			}
		}

		return inferables
	} # }}}
	isAssigningBinding() => true
	isDeclararing() => true
	toFragments(fragments, mode) { # {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}

		fragments.code(' ? ')

		if @left.toAssignmentFragments? {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(' : null')
	} # }}}
	toBooleanFragments(fragments, mode, junction) { # {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}

		fragments.code(' ? (')

		if @left.toAssignmentFragments? {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(', true) : false')
	} # }}}
	toQuote() { # {{{
		return `\(@left.toQuote()) ?= \(@right.toQuote())`
	} # }}}
	type() => @scope.reference('Boolean')
}

class AssignmentOperatorLeftShift extends NumericAssignmentOperatorExpression {
	operator() => Operator::LeftShift
	runtime() => 'leftShift'
	symbol() => '<<='
}

class AssignmentOperatorModulo extends NumericAssignmentOperatorExpression {
	operator() => Operator::Modulo
	runtime() => 'modulo'
	symbol() => '%='
}

class AssignmentOperatorMultiplication extends NumericAssignmentOperatorExpression {
	operator() => Operator::Multiplication
	runtime() => 'multiplication'
	symbol() => '*='
}

class AssignmentOperatorNonExistential extends AssignmentOperatorExpression {
	private {
		@condition: Boolean		= false
		@lateinit: Boolean		= false
	}
	analyse() { # {{{
		@condition = @statement() is IfStatement

		super()
	} # }}}
	override prepare(target) { # {{{
		super()

		@right.acquireReusable(true)
		@right.releaseReusable()

		if @left is IdentifierLiteral {
			var type = @right.type().setNullable(false)

			if @condition {
				if @lateinit {
					@statement.initializeLateVariable(@left.name(), type, false)
				}
				else if var scope = @statement.getWhenFalseScope() {
					@left.type(type, scope, this)
				}
			}
			else {
				@left.type(type, @scope, this)
			}
		}
	} # }}}
	defineVariables(left) { # {{{
		if @condition {
			var scope = @statement.scope()
			var names = []

			for var name in left.listAssignments([]) {
				if var variable = scope.getVariable(name) {
					if variable.isLateInit() {
						if @parent == @statement {
							@statement.addInitializableVariable(variable, false, this)
						}
						else {
							throw new NotImplementedException(this)
						}

						@lateinit = true
					}
					else if variable.isImmutable() {
						ReferenceException.throwImmutable(name, this)
					}
				}
				else {
					names.push(name)
				}
			}

			if names.length > 0 {
				@statement.defineVariables(left, names, @scope, @leftMost, @leftMost == this)
			}
		}
		else {
			@statement.defineVariables(left, @scope, @leftMost, @leftMost == this)
		}
	} # }}}
	inferWhenFalseTypes(inferables) { # {{{
		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @right.type().setNullable(false)
			}
		}

		return inferables
	} # }}}
	isAssigningBinding() => true
	isDeclararing() => true
	toFragments(fragments, mode) { # {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}

		fragments
			.code(' ? ')
			.compile(@left)
			.code($equals)
			.wrap(@right)
			.code(' : null')
	} # }}}
	toBooleanFragments(fragments, mode, junction) { # {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}

		fragments
			.code(' ? (')
			.compile(@left)
			.code($equals)
			.wrap(@right)
			.code(', false) : true')
	} # }}}
	type() => @scope.reference('Boolean')
}

class AssignmentOperatorNullCoalescing extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { # {{{
		if @left.isNullable() {
			fragments.code('(')

			@left.toNullableFragments(fragments)

			fragments
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compile(@left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compile(@left)
				.code(')')
		}

		fragments
			.code(' ? null : ')
			.compile(@left)
			.code($equals)
			.compile(@right)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var mut ctrl = fragments.newControl()

		ctrl.code('if(!')

		if @left.isNullable() {
			ctrl.code('(')

			@left.toNullableFragments(ctrl)

			ctrl
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compile(@left)
				.code('))')
		}
		else {
			ctrl
				.code($runtime.type(this) + '.isValue(')
				.compile(@left)
				.code(')')
		}

		ctrl
			.code(')')
			.step()
			.newLine()
			.compile(@left)
			.code($equals)
			.compile(@right)
			.done()

		ctrl.done()
	} # }}}
}

class AssignmentOperatorOr extends LogicalAssignmentOperatorExpression {
	native() => @operand == OperandType::Boolean ? '||' : '|='
	operator() => Operator::Or
	runtime() => 'or'
	symbol() => '||='
	toEnumFragments(fragments) { # {{{
		// fragments.compile(@left).code($equals, @type.name(), '(').compile(@left).code(' | ').compile(@right).code(')')
	} # }}}
}

class AssignmentOperatorQuotient extends NumericAssignmentOperatorExpression {
	operator() => Operator::Quotient
	runtime() => 'quotient'
	symbol() => '/.='
	toNativeFragments(fragments) { # {{{
		fragments.compile(@left).code($equals).code('Number.parseInt(').compile(@left).code(' / ').compile(@right).code(')')
	} # }}}
}

class AssignmentOperatorRightShift extends NumericAssignmentOperatorExpression {
	operator() => Operator::RightShift
	runtime() => 'rightShift'
	symbol() => '>>='
}

class AssignmentOperatorSubtraction extends NumericAssignmentOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::Subtraction
	runtime() => 'subtraction'
	symbol() => '-='
	toEnumFragments(fragments) { # {{{
		fragments.compile(@left).code($equals, @type.name(), '(').compile(@left).code(' & ~')

		@right.toOperandFragments(fragments, Operator::Subtraction, OperandType::Enum)

		fragments.code(')')
	} # }}}
}

class AssignmentOperatorXor extends LogicalAssignmentOperatorExpression {
	native() => '^='
	operator() => Operator::Xor
	runtime() => 'xor'
	symbol() => '^^='
	toNativeFragments(fragments) { # {{{
		if @operand == OperandType::Boolean {
			fragments.compile(@left).code(' = ').compile(@left).code(` !== `).compile(@right)
		}
		else {
			fragments.compile(@left).code($space).code(@native(), @data.operator).code($space).compile(@right)
		}
	} # }}}
}
