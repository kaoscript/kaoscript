class AssignmentOperatorExpression extends Expression {
	private lateinit {
		_await: Boolean				= false
		_bindingScope: Scope
		_left						= null
		_right						= null
	}
	analyse() { // {{{
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
	} // }}}
	prepare() { // {{{
		@left.flagAssignable()

		@left.prepare()

		if const variable = @left.variable() {
			if variable.isInitialized() {
				@right.setExpectedType(variable.getRealType())
			}
			else {
				@right.setExpectedType(variable.getDeclaredType())
			}
		}
		else {
			@right.setExpectedType(@left.type())
		}

		@right.prepare()

		if @right.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@right, this)
		}
	} // }}}
	translate() { // {{{
		@left.translate()
		@right.translate()
	} // }}}
	defineVariables(left) { // {{{
		const statement = @statement()

		statement.defineVariables(left, @scope, @leftMost, @leftMost == this)
	} // }}}
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
	listAssignments(array) => @left.listAssignments(@right.listAssignments(array))
	setAssignment(assignment)
	toNullableFragments(fragments) { // {{{
		fragments.compileNullable(@right)
	} // }}}
	variable() => @left.variable()
}

abstract class NumericAssignmentOperatorExpression extends AssignmentOperatorExpression {
	private lateinit {
		_isEnum: Boolean		= false
		_isNative: Boolean		= false
		_type: Type
	}
	prepare() { // {{{
		super()

		if this.isAcceptingEnum() && @left.type().isEnum() && @right.type().isEnum() && @left.type().name() == @right.type().name() {
			@isEnum = true

			@type = @left.type()
		}
		else {
			if @left.type().isNumber() && @right.type().isNumber() {
				@isNative = true
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

				@isNative = false
			}
			else {
				@type = @scope.reference('Number')
			}

			if @left is IdentifierLiteral {
				@left.type(@type, @scope, this)
			}
		}
	} // }}}
	isAcceptingEnum() => false
	abstract operator(): Operator
	abstract runtime(): String
	abstract symbol(): String
	toFragments(fragments, mode) { // {{{
		if @isEnum {
			this.toEnumFragments(fragments)
		}
		else if @isNative {
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
	} // }}}
	toEnumFragments(fragments)
	toNativeFragments(fragments) { // {{{
		fragments.compile(@left).code($space).code(this.symbol(), @data.operator).code($space).compile(@right)
	} // }}}
	toQuote() => `\(@left.toQuote()) \(this.symbol()) \(@right.toQuote())`
	type() => @type
}

class AssignmentOperatorAddition extends AssignmentOperatorExpression {
	private lateinit {
		_isEnum: Boolean		= false
		_isNative: Boolean		= false
		_isNumber: Boolean		= false
		_isString: Boolean		= false
		_type: Type
	}
	prepare() { // {{{
		super()

		if @left.type().isEnum() && @right.type().isEnum() && @left.type().name() == @right.type().name() {
			@isEnum = true

			@type = @left.type()
		}
		else {
			if @left.type().isString() || @right.type().isString() {
				@isString = true
				@isNative = true
			}
			else if @left.type().isNumber() && @right.type().isNumber() {
				@isNumber = true
				@isNative = true
			}
			else if (@left.type().canBeString(false) && !@left.type().canBeNumber(false)) || (@right.type().canBeString(false) && !@right.type().canBeNumber(false)) {
				@isString = true
			}
			else if @left.type().isAny() || @right.type().isAny() {
			}
			else if @left.type().canBeNumber() {
				if !@left.type().canBeString(false) {
					if @right.type().canBeNumber() {
						if !@right.type().canBeString(false) {
							@isNumber = true
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

			const nullable = @left.type().isNullable() || @right.type().isNullable()
			if nullable {
				@isNative = false
			}

			if @isNumber {
				@type = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')
			}
			else if @isString {
				@type = @scope.reference('String')
			}
			else {
				const numberType = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')

				@type = new UnionType(@scope, [numberType, @scope.reference('String')], false)
			}
		}

		if @left is IdentifierLiteral {
			@left.type(@type, @scope, this)
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @isEnum {
			fragments.compile(@left).code($equals, @type.name(), '(').compile(@left).code(' | ')

			@right.toOperandFragments(fragments, Operator::Addition, OperandType::Enum)

			fragments.code(')')
		}
		else if @isNative {
			fragments.compile(@left).code(' += ').compile(@right)
		}
		else {
			fragments.compile(@left).code(' = ')

			let type
			if @isNumber {
				fragments.code($runtime.operator(this), '.addition(')

				type = OperandType::Number
			}
			else if @isString {
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
	} // }}}
	type() => @type
}

class AssignmentOperatorBitwiseAnd extends NumericAssignmentOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::BitwiseAnd
	runtime() => 'bitwiseAnd'
	symbol() => '&='
	toEnumFragments(fragments) { // {{{
		fragments.compile(@left).code($equals, @type.name(), '(').compile(@left).code(' & ').compile(@right).code(')')
	} // }}}
}

class AssignmentOperatorBitwiseLeftShift extends NumericAssignmentOperatorExpression {
	operator() => Operator::BitwiseLeftShift
	runtime() => 'bitwiseLeftShift'
	symbol() => '<<='
}

class AssignmentOperatorBitwiseOr extends NumericAssignmentOperatorExpression {
	getEnumSymbol() => '|'
	isAcceptingEnum() => true
	operator() => Operator::BitwiseOr
	runtime() => 'bitwiseOr'
	symbol() => '|='
	toEnumFragments(fragments) { // {{{
		fragments.compile(@left).code($equals, @type.name(), '(').compile(@left).code(' | ').compile(@right).code(')')
	} // }}}
}

class AssignmentOperatorBitwiseRightShift extends NumericAssignmentOperatorExpression {
	operator() => Operator::BitwiseRightShift
	runtime() => 'bitwiseRightShift'
	symbol() => '>>='
}

class AssignmentOperatorBitwiseXor extends NumericAssignmentOperatorExpression {
	operator() => Operator::BitwiseXor
	runtime() => 'bitwiseXor'
	symbol() => '^='
}

class AssignmentOperatorDivision extends NumericAssignmentOperatorExpression {
	operator() => Operator::Division
	runtime() => 'division'
	symbol() => '/='
}

class AssignmentOperatorEquality extends AssignmentOperatorExpression {
	private lateinit {
		@condition: Boolean		= false
		@ignorable: Boolean		= false
		@lateinit: Boolean		= false
		@type: Type
	}
	analyse() { // {{{
		@condition = @statement() is IfStatement

		super()
	} // }}}
	prepare() { // {{{
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
	} // }}}
	acquireReusable(acquire) { // {{{
		@right.acquireReusable(@left.isSplitAssignment())
	} // }}}
	defineVariables(left) { // {{{
		if @condition {
			const names = []

			for const name in left.listAssignments([]) {
				if const variable = @scope.getVariable(name) {
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
	} // }}}
	flagAssignable()
	hasExceptions() => @right.isAwaiting() && @right.hasExceptions()
	inferTypes(inferables) { // {{{
		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @type
			}
		}

		return inferables
	} // }}}
	initializeVariable(variable: VariableBrief) { // {{{
		@parent.initializeVariable(variable, this)
	} // }}}
	initializeVariable(variable: VariableBrief, expression: Expression) { // {{{
		@parent.initializeVariable(variable, expression)
	} // }}}
	initializeVariables(type: Type, node: Expression)
	isAssigningBinding() => true
	isDeclarable() => @left.isDeclarable()
	isDeclararing() => true
	isIgnorable() => @ignorable
	private isInDestructor() { // {{{
		if @parent is not ExpressionStatement {
			return false
		}

		let parent = @parent

		while parent? {
			parent = parent.parent()

			if parent is ClassDestructorDeclaration {
				return true
			}
		}

		return false
	} // }}}
	releaseReusable() { // {{{
		@right.releaseReusable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @right.isAwaiting() {
			return @right.toFragments(fragments, mode)
		}
		else if @left.isUsingSetter() {
			@left.toSetterFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).compile(@right)
		}
	} // }}}
	toAssignmentFragments(fragments) { // {{{
		if @left.toAssignmentFragments? {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).compile(@right)
		}
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		fragments.compile(@left).code($equals).wrap(@right)
	} // }}}
	toQuote() => `\(@left.toQuote()) = \(@right.toQuote())`
	type() => @type
}

class AssignmentOperatorExistential extends AssignmentOperatorExpression {
	private {
		@condition: Boolean		= false
		@lateinit: Boolean		= false
	}
	analyse() { // {{{
		@condition = @statement() is IfStatement

		super()
	} // }}}
	prepare() { // {{{
		super()

		@right.acquireReusable(true)
		@right.releaseReusable()

		if @left is IdentifierLiteral {
			const type = @right.type().setNullable(false)

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
	} // }}}
	defineVariables(left) { // {{{
		if @condition {
			const names = []

			for const name in left.listAssignments([]) {
				if const variable = @scope.getVariable(name) {
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
	} // }}}
	inferWhenTrueTypes(inferables) { // {{{
		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @right.type().setNullable(false)
			}
		}

		return inferables
	} // }}}
	isAssigningBinding() => true
	isDeclararing() => true
	toFragments(fragments, mode) { // {{{
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
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
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
	} // }}}
	toQuote() { // {{{
		return `\(@left.toQuote()) ?= \(@right.toQuote())`
	} // }}}
	type() => @scope.reference('Boolean')
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
	analyse() { // {{{
		@condition = @statement() is IfStatement

		super()
	} // }}}
	prepare() { // {{{
		super()

		@right.acquireReusable(true)
		@right.releaseReusable()

		if @left is IdentifierLiteral {
			const type = @right.type().setNullable(false)

			if @condition {
				if @lateinit {
					@statement.initializeLateVariable(@left.name(), type, false)
				}
				else if const scope = @statement.getWhenFalseScope() {
					@left.type(type, scope, this)
				}
			}
			else {
				@left.type(type, @scope, this)
			}
		}
	} // }}}
	defineVariables(left) { // {{{
		if @condition {
			const scope = @statement.scope()
			const names = []

			for const name in left.listAssignments([]) {
				if const variable = scope.getVariable(name) {
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
	} // }}}
	inferWhenFalseTypes(inferables) { // {{{
		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @right.type().setNullable(false)
			}
		}

		return inferables
	} // }}}
	isAssigningBinding() => true
	isDeclararing() => true
	toFragments(fragments, mode) { // {{{
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
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
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
	} // }}}
	type() => @scope.reference('Boolean')
}

class AssignmentOperatorNullCoalescing extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
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
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()

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
	} // }}}
}

class AssignmentOperatorQuotient extends NumericAssignmentOperatorExpression {
	operator() => Operator::Quotient
	runtime() => 'quotient'
	symbol() => '/.='
	toNativeFragments(fragments) { // {{{
		fragments.compile(@left).code($equals).code('Number.parseInt(').compile(@left).code(' / ').compile(@right).code(')')
	} // }}}
}

class AssignmentOperatorSubtraction extends NumericAssignmentOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::Subtraction
	runtime() => 'subtraction'
	symbol() => '-='
	toEnumFragments(fragments) { // {{{
		fragments.compile(@left).code($equals, @type.name(), '(').compile(@left).code(' & ~')

		@right.toOperandFragments(fragments, Operator::Subtraction, OperandType::Enum)

		fragments.code(')')
	} // }}}
}
