class BinaryOperatorExpression extends Expression {
	private {
		_await: Boolean		= false
		_left
		_right
		_tested: Boolean	= false
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()

		@right = $compile.expression(@data.right, this)
		@right.analyse()

		@await = @left.isAwait() || @right.isAwait()
	} // }}}
	prepare() { // {{{
		@left.prepare()

		if @left.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
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
	acquireReusable(acquire) { // {{{
		@left.acquireReusable(false)
		@right.acquireReusable(false)
	} // }}}
	hasExceptions() => false
	inferTypes(inferables) => @right.inferTypes(@left.inferTypes(inferables))
	isAwait() => @await
	isAwaiting() => @left.isAwaiting() || @right.isAwaiting()
	isComputed() => true
	isNullable() => @left.isNullable() || @right.isNullable()
	isNullableComputed() => (@left.isNullable() && @right.isNullable()) || @left.isNullableComputed() || @right.isNullableComputed()
	isUsingVariable(name) => @left.isUsingVariable(name) || @right.isUsingVariable(name)
	isUsingInstanceVariable(name) => @left.isUsingInstanceVariable(name) || @right.isUsingInstanceVariable(name)
	isUsingStaticVariable(class, varname) => @left.isUsingStaticVariable(class, varname) || @right.isUsingStaticVariable(class, varname)
	listAssignments(array) { // {{{
		@left.listAssignments(array)
		@right.listAssignments(array)

		return array
	} // }}}
	listNonLocalVariables(scope: Scope, variables: Array) { // {{{
		@left.listNonLocalVariables(scope, variables)
		@right.listNonLocalVariables(scope, variables)

		return variables
	} // }}}
	releaseReusable() { // {{{
		@left.releaseReusable()
		@right.releaseReusable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @await {
			if @left.isAwaiting() {
				return @left.toFragments(fragments, mode)
			}
			else if @right.isAwaiting() {
				return @right.toFragments(fragments, mode)
			}
			else {
				this.toOperatorFragments(fragments)
			}
		}
		else if this.isNullable() && !@tested {
			fragments
				.wrapNullable(this)
				.code(' ? ')

			this.toOperatorFragments(fragments)

			fragments.code(' : false')
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !@tested {
			if @left.isNullable() {
				fragments.compileNullable(@left)

				if @right.isNullable() {
					fragments.code(' && ').compileNullable(@right)
				}
			}
			else {
				fragments.compileNullable(@right)
			}

			@tested = true
		}
	} // }}}
}

abstract class NumericBinaryOperatorExpression extends BinaryOperatorExpression {
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
		}
	} // }}}
	translate() { // {{{
		super()

		if @isEnum {
			const type = @parent.type()

			if @parent is AssignmentOperatorEquality || @parent is VariableDeclaration {
				if type.isEnum() {
					if @type.name() != type.name() {
						@isEnum = false
						@isNative = true
					}
				}
				else if type.isNumber() {
					@isEnum = false
					@isNative = true
				}
			}
			else if type.isBoolean() || (type.isEnum() && @type.name() == type.name()) {
				@isEnum = false
				@isNative = true
			}
		}
	} // }}}
	isAcceptingEnum() => false
	isComputed() => @isNative
	abstract operator(): Operator
	abstract runtime(): String
	abstract symbol(): String
	toEnumFragments(fragments)
	toNativeFragments(fragments) { // {{{
		fragments.wrap(@left).code($space).code(this.symbol(), @data.operator).code($space).wrap(@right)
	} // }}}
	toOperandFragments(fragments, operator, type) { // {{{
		if operator == this.operator() && type == OperandType::Number {
			fragments.compile(@left).code($comma).compile(@right)
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} // }}}
	toOperatorFragments(fragments) { // {{{
		if @isEnum {
			this.toEnumFragments(fragments)
		}
		else if @isNative {
			this.toNativeFragments(fragments)
		}
		else {
			fragments
				.code($runtime.operator(this), `.\(this.runtime())(`)
				.compile(@left)
				.code($comma)
				.compile(@right)
				.code(')')
		}
	} // }}}
	toQuote() => `\(@left.toQuote()) \(this.symbol()) \(@right.toQuote())`
	type() => @type
}

class BinaryOperatorAddition extends BinaryOperatorExpression {
	private lateinit {
		_expectingEnum: Boolean		= true
		_isEnum: Boolean			= false
		_isNative: Boolean			= false
		_isNumber: Boolean			= false
		_isString: Boolean			= false
		_type: Type
	}
	prepare() { // {{{
		super()

		if @left.type().isEnum() && @right.type().isEnum() && @left.type().name() == @right.type().name() {
			@isEnum = true

			if @expectingEnum {
				@type = @left.type()
			}
			else {
				@type = @left.type().discard().type()
			}
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
	} // }}}
	isComputed() => @isNative
	override setExpectedType(type) { // {{{
		if !type.isEnum() && (type.isNumber() || type.isString()) {
			@expectingEnum = false
		}
	} // }}}
	toOperandFragments(fragments, operator, type) { // {{{
		if operator == Operator::Addition {
			if type == OperandType::Enum && (@isEnum || @isNumber) {
				fragments.wrap(@left).code(' | ').wrap(@right)
			}
			else if ((@isNumber && type == OperandType::Number) || (@isString && type == OperandType::String)) {
				fragments.compile(@left).code($comma).compile(@right)
			}
			else {
				this.toOperatorFragments(fragments)
			}
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} // }}}
	toOperatorFragments(fragments) { // {{{
		if @isEnum {
			lateinit const operator: String

			if @left.type().discard().isFlags() {
				operator = ' | '
			}
			else {
				operator = ' + '
			}

			if @expectingEnum {
				fragments.code(@type.name(), '(').wrap(@left).code(operator).wrap(@right).code(')')
			}
			else {
				fragments.wrap(@left).code(operator).wrap(@right)
			}
		}
		else if @isNative {
			fragments
				.wrap(@left)
				.code($space)
				.code('+', @data.operator)
				.code($space)
				.wrap(@right)
		}
		else {
			if @isNumber {
				fragments.code($runtime.operator(this), '.addition(')
			}
			else if @isString {
				fragments.code($runtime.helper(this), '.concatString(')
			}
			else {
				fragments.code($runtime.operator(this), '.addOrConcat(')
			}

			fragments.compile(@left).code($comma).compile(@right).code(')')
		}
	} // }}}
	toQuote() => `\(@left.toQuote()) + \(@right.toQuote())`
	type() => @type
}

class BinaryOperatorBitwiseAnd extends NumericBinaryOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::BitwiseAnd
	runtime() => 'bitwiseAnd'
	symbol() => '&'
	toEnumFragments(fragments) { // {{{
		fragments.code(@type.name(), '(')

		this.toNativeFragments(fragments)

		fragments.code(')')
	} // }}}
}

class BinaryOperatorBitwiseLeftShift extends NumericBinaryOperatorExpression {
	operator() => Operator::BitwiseLeftShift
	runtime() => 'bitwiseLeftShift'
	symbol() => '<<'
}

class BinaryOperatorBitwiseOr extends NumericBinaryOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::BitwiseOr
	runtime() => 'bitwiseOr'
	symbol() => '|'
	toEnumFragments(fragments) { // {{{
		fragments.code(@type.name(), '(')

		this.toNativeFragments(fragments)

		fragments.code(')')
	} // }}}
}

class BinaryOperatorBitwiseRightShift extends NumericBinaryOperatorExpression {
	operator() => Operator::BitwiseRightShift
	runtime() => 'bitwiseRightShift'
	symbol() => '>>'
}

class BinaryOperatorBitwiseXor extends NumericBinaryOperatorExpression {
	operator() => Operator::BitwiseXor
	runtime() => 'bitwiseXor'
	symbol() => '^'
}

class BinaryOperatorDivision extends NumericBinaryOperatorExpression {
	operator() => Operator::Division
	runtime() => 'division'
	symbol() => '/'
}

class BinaryOperatorMatch extends Expression {
	private lateinit {
		_await: Boolean				= false
		_composite: Boolean			= false
		_isNative: Boolean			= true
		_junction: String
		_junctive: Boolean			= false
		_operands					= []
		_reuseName: String?			= null
		_subject
		_tested: Boolean			= false
	}
	analyse() { // {{{
		@subject = $compile.expression(@data.left, this)
		@subject.analyse()

		if @data.right.kind == NodeKind::JunctionExpression {
			@junctive = true

			for const operand in @data.right.operands {
				this.addOperand(operand)
			}

			if @data.right.operator.kind == BinaryOperatorKind::And {
				@junction = ' && '
			}
			else if @data.right.operator.kind == BinaryOperatorKind::Or {
				@junction = ' || '
			}
		}
		else {
			this.addOperand(@data.right)
		}
	} // }}}
	prepare() { // {{{
		@subject.prepare()

		if @subject.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@subject, this)
		}

		unless @subject.type().canBeNumber() {
			TypeException.throwInvalidOperand(@subject, Operator::Match, this)
		}

		if !@subject.type().isNumber() || @subject.type().isNullable() {
			@isNative = false
		}

		for const operand in @operands {
			operand.prepare()

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			unless operand.type().canBeNumber() {
				TypeException.throwInvalidOperand(operand, Operator::Match, this)
			}
		}
	} // }}}
	translate() { // {{{
		@subject.translate()

		for const operand in @operands {
			operand.translate()
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		if @junctive && @subject.isComposite() {
			@composite = true

			@reuseName = @scope.acquireTempName()
		}

		@subject.acquireReusable(acquire)

		for const operand in @operands {
			operand.acquireReusable(acquire)
		}
	} // }}}
	private addOperand(data) { // {{{
		const operand = $compile.expression(data, this)

		operand.analyse()

		@operands.push(operand)

		if operand.isAwait() {
			@await = true
		}
	} // }}}
	inferTypes(inferables) => @subject.inferTypes(inferables)
	isComputed() => true
	operator() => '!=='
	releaseReusable() { // {{{
		if @composite {
			@scope.releaseTempName(@reuseName)
		}

		@subject.releaseReusable()

		for const operand in @operands {
			operand.releaseReusable()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @await {
			NotSupportedException.throw(this)
		}

		const test = this.isNullable() && !@tested
		if test {
			fragments.wrapNullable(this).code(' ? ')
		}

		if @junctive {
			if !?@junction {
				fragments.code($runtime.operator(this), '.xor(')

				this.toOperatorFragments(fragments, @operands[0], true)

				for const operand in @operands from 1 {
					fragments.code($comma)

					this.toOperatorFragments(fragments, operand, false)
				}

				fragments.code(')')
			}
			else {
				this.toOperatorFragments(fragments, @operands[0], true)

				for const operand in @operands from 1 {
					fragments.code(@junction)

					this.toOperatorFragments(fragments, operand, false)
				}
			}
		}
		else {
			this.toOperatorFragments(fragments, @operands[0], false)
		}

		if test {
			fragments.code(' : false')
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !@tested {
			let nf = false

			if @subject.isNullable() {
				nf = true

				fragments.compileNullable(@subject)
			}

			for const operand in @operands {
				if operand.isNullable() {
					if nf {
						fragments.code(' && ')
					}
					else {
						nf = true
					}

					fragments.compileNullable(operand)
				}
			}

			@tested = true
		}
	} // }}}
	toOperatorFragments(fragments, operand, assignable) { // {{{
		const native = @isNative && operand.type().isNumber() && !operand.type().isNullable()
		const operator = this.operator()

		if @composite {
			if assignable {
				if native {
					fragments.code(`((\(@reuseName) = `).compile(@subject).code(') & ').wrap(operand).code(`) \(operator) 0`)
				}
				else {
					fragments
						.code($runtime.operator(this), `.bitwiseAnd(\(@reuseName) = `)
						.compile(@subject)
						.code($comma)
						.compile(operand)
						.code(`) \(operator) 0`)
				}
			}
			else {
				if native {
					fragments.code(`(\(@reuseName) & `).wrap(operand).code(`) \(operator) 0`)
				}
				else {
					fragments.code($runtime.operator(this), `.bitwiseAnd(\(@reuseName), `).compile(operand).code(`) \(operator) 0`)
				}
			}
		}
		else {
			if native {
				fragments.code('(').wrap(@subject).code(' & ').wrap(operand).code(`) \(operator) 0`)
			}
			else {
				fragments
					.code($runtime.operator(this), `.bitwiseAnd(`)
					.compile(@subject)
					.code($comma)
					.compile(operand)
					.code(`) \(operator) 0`)
			}
		}
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorMismatch extends BinaryOperatorMatch {
	operator() => '==='
}

class BinaryOperatorModulo extends NumericBinaryOperatorExpression {
	operator() => Operator::Modulo
	runtime() => 'modulo'
	symbol() => '%'
}

class BinaryOperatorMultiplication extends NumericBinaryOperatorExpression {
	operator() => Operator::Multiplication
	runtime() => 'multiplication'
	symbol() => '*'
}

class BinaryOperatorNullCoalescing extends BinaryOperatorExpression {
	private lateinit {
		_type: Type
	}
	prepare() { // {{{
		super()

		@left.acquireReusable(true)
		@left.releaseReusable()

		const leftType = @left.type().setNullable(false)

		if leftType.equals(@right.type()) {
			@type = leftType
		}
		else {
			@type = Type.union(@scope, leftType, @right.type())
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		@left.acquireReusable(true)
	} // }}}
	releaseReusable() { // {{{
		@left.releaseReusable()
	} // }}}
	inferTypes(inferables) => @left.inferTypes(inferables)
	toFragments(fragments, mode) { // {{{
		if @left.isNullable() {
			fragments.code('(')

			@left.toNullableFragments(fragments)

			fragments
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compileReusable(@left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compileReusable(@left)
				.code(')')
		}

		fragments
			.code(' ? ')
			.compile(@left)
			.code(' : ')
			.compile(@right)
	} // }}}}
	type() => @type
}

class BinaryOperatorQuotient extends NumericBinaryOperatorExpression {
	operator() => Operator::Quotient
	runtime() => 'quotient'
	symbol() => '/.'
	toNativeFragments(fragments) { // {{{
		fragments.code('Number.parseInt(').wrap(@left).code(' / ').wrap(@right).code(')')
	} // }}}
}

class BinaryOperatorSubtraction extends NumericBinaryOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::Subtraction
	runtime() => 'subtraction'
	symbol() => '-'
	toOperandFragments(fragments, operator, type) { // {{{
		if operator == Operator::Subtraction {
			if type == OperandType::Enum {
				fragments.wrap(@left).code(' & ~').wrap(@right)
			}
			else {
				fragments.compile(@left).code($comma).compile(@right)
			}
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} // }}}
	toEnumFragments(fragments) { // {{{
		fragments.code(@type.name(), '(').wrap(@left).code(' & ~').wrap(@right).code(')')
	} // }}}
}

class BinaryOperatorTypeCasting extends Expression {
	private lateinit {
		_forced: Boolean	= false
		_left
		_nullable: Boolean	= false
		_type: Type
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()

		@type = Type.fromAST(@data.right, this)

		for const modifier in @data.operator.modifiers {
			if modifier.kind == ModifierKind::Forced {
				@forced = true
			}
			else if modifier.kind == ModifierKind::Nullable {
				@nullable = true

				@type = @type.setNullable(true)
			}
		}
	} // }}}
	prepare() { // {{{
		@left.prepare()

		const type = @left.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		if !(type is ReferenceType || type is UnionType || type.isAny()) {
			TypeException.throwInvalidCasting(this)
		}
	} // }}}
	translate() { // {{{
		@left.translate()
	} // }}}
	hasExceptions() => false
	inferTypes(inferables) => @left.inferTypes(inferables)
	isComputed() => false
	isNullable() => @left.isNullable()
	isUsingVariable(name) => @left.isUsingVariable(name)
	isUsingInstanceVariable(name) => @left.isUsingInstanceVariable(name)
	listAssignments(array) => @left.listAssignments(array)
	name() => @left is IdentifierLiteral ? @left.name() : null
	toFragments(fragments, mode) { // {{{
		if @forced || @left.type().isAssignableToVariable(@type, false, false, false) {
			fragments.compile(@left)
		}
		else if !@nullable && @left.type().isAssignableToVariable(@type, false, true, false) {
			fragments.code($runtime.helper(this), '.notNull(').compile(@left).code(')')
		}
		else if @type.isAssignableToVariable(@left.type(), true, @nullable, true) {
			fragments.code($runtime.helper(this), '.cast(').compile(@left).code($comma, $quote(@type.name()), $comma, @nullable)

			@type.toCastFragments(fragments)

			fragments.code(')')
		}
		else {
			TypeException.throwNotCastableTo(@left.type(), @type, this)
		}
	} // }}}
	type() => @type
}

class BinaryOperatorTypeEquality extends Expression {
	private lateinit {
		_falseType: Type
		_subject
		_trueType: Type
	}
	analyse() { // {{{
		@subject = $compile.expression(@data.left, this)
		@subject.analyse()

	} // }}}
	prepare() { // {{{
		@subject.prepare()

		if @subject.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@subject, this)
		}

		if @data.right.kind == NodeKind::JunctionExpression {
			lateinit const type: Type

			if @data.right.operator.kind == BinaryOperatorKind::And {
				type = new FusionType(@scope)
			}
			else {
				type = new UnionType(@scope)
			}

			for const operand in @data.right.operands {
				if operand.kind == NodeKind::TypeReference && operand.typeName?.kind == NodeKind::Identifier {
					if const variable = @scope.getVariable(operand.typeName.name) {
						type.addType(this.validateType(variable))
					}
					else {
						ReferenceException.throwNotDefined(operand.typeName.name, this)
					}
				}
				else {
					throw new NotImplementedException(this)
				}
			}

			@trueType = type.type()
		}
		else {
			if @data.right.kind == NodeKind::TypeReference && @data.right.typeName?.kind == NodeKind::Identifier {
				if const variable = @scope.getVariable(@data.right.typeName.name) {
					@trueType = this.validateType(variable)
				}
				else {
					ReferenceException.throwNotDefined(@data.right.typeName.name, this)
				}
			}
			else {
				throw new NotImplementedException(this)
			}
		}

		if @subject.isInferable() {
			@falseType = @subject.type().reduce(@trueType)
		}
	} // }}}
	translate() { // {{{
		@subject.translate()
	} // }}}
	hasExceptions() => false
	inferWhenTrueTypes(inferables) { // {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject is IdentifierLiteral
				isTyping: true
				type: @trueType
			}
		}

		return inferables
	} // }}}
	inferWhenFalseTypes(inferables) { // {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject is IdentifierLiteral
				type: @falseType
			}
		}

		return inferables
	} // }}}
	isComputed() => false
	isNullable() => false
	isUsingVariable(name) => @subject.isUsingVariable(name)
	isUsingInstanceVariable(name) => @subject.isUsingInstanceVariable(name)
	listAssignments(array) => @subject.listAssignments(array)
	toFragments(fragments, mode) { // {{{
		@trueType.toPositiveTestFragments(fragments, @subject)
	} // }}}
	type() => @scope.reference('Boolean')
	private validateType(variable) { // {{{
		const type = variable.getRealType()

		if @subject.type().isNull() {
			TypeException.throwNullTypeChecking(type, this)
		}

		if type.isVirtual() {
			if !@subject.type().isAny() && !@subject.type().canBeVirtual(type.name()) {
				TypeException.throwInvalidTypeChecking(@subject.type(), type, this)
			}
		}
		else if type.isClass() || type.isEnum() || type.isStruct() || type.isTuple() || type.isUnion() || type.isFusion() || type.isExclusion() {
			unless type.isAssignableToVariable(@subject.type(), true) {
				TypeException.throwInvalidTypeChecking(@subject.type(), type, this)
			}
		}
		else {
			TypeException.throwNotClass(variable.name(), this)
		}

		return type.reference()
	} // }}}
}

class BinaryOperatorTypeInequality extends Expression {
	private lateinit {
		_falseType: Type
		_subject
		_trueType: Type
	}
	analyse() { // {{{
		@subject = $compile.expression(@data.left, this)
		@subject.analyse()

	} // }}}
	prepare() { // {{{
		@subject.prepare()

		if @subject.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@subject, this)
		}

		if @data.right.kind == NodeKind::JunctionExpression {
			lateinit const type: Type

			if @data.right.operator.kind == BinaryOperatorKind::And {
				type = new FusionType(@scope)
			}
			else {
				type = new UnionType(@scope)
			}

			for const operand in @data.right.operands {
				if operand.kind == NodeKind::TypeReference && operand.typeName?.kind == NodeKind::Identifier {
					if const variable = @scope.getVariable(operand.typeName.name) {
						type.addType(this.validateType(variable))
					}
					else {
						ReferenceException.throwNotDefined(operand.typeName.name, this)
					}
				}
				else {
					throw new NotImplementedException(this)
				}
			}

			@falseType = type.type()
		}
		else {
			if @data.right.kind == NodeKind::TypeReference && @data.right.typeName?.kind == NodeKind::Identifier {
				if const variable = @scope.getVariable(@data.right.typeName.name) {
					@falseType = this.validateType(variable)
				}
				else {
					ReferenceException.throwNotDefined(@data.right.typeName.name, this)
				}
			}
			else {
				throw new NotImplementedException(this)
			}
		}

		if @subject.isInferable() {
			@trueType = @subject.type().reduce(@falseType)
		}
	} // }}}
	translate() { // {{{
		@subject.translate()
	} // }}}
	hasExceptions() => false
	inferTypes(inferables) => @subject.inferTypes(inferables)
	isComputed() => false
	isNullable() => false
	isUsingVariable(name) => @subject.isUsingVariable(name)
	isUsingInstanceVariable(name) => @subject.isUsingInstanceVariable(name)
	inferWhenTrueTypes(inferables) { // {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject is IdentifierLiteral
				isTyping: true
				type: @trueType
			}
		}

		return inferables
	} // }}}
	inferWhenFalseTypes(inferables) { // {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject is IdentifierLiteral
				type: @falseType
			}
		}

		return inferables
	} // }}}
	listAssignments(array) => @subject.listAssignments(array)
	toFragments(fragments, mode) { // {{{
		@falseType.toNegativeTestFragments(fragments, @subject)
	} // }}}
	type() => @scope.reference('Boolean')
	private validateType(variable) { // {{{
		const type = variable.getRealType()

		if @subject.type().isNull() {
			TypeException.throwNullTypeChecking(type, this)
		}

		if type.isVirtual() {
			if !@subject.type().isAny() && !@subject.type().canBeVirtual(type.name()) {
				TypeException.throwUnnecessaryTypeChecking(@subject.type(), this)
			}
		}
		else if type.isEnum() || type.isStruct() || type.isTuple() || type.isUnion() || type.isFusion() || type.isExclusion() {
			if !@subject.type().isAny() && !type.matchContentOf(@subject.type()) {
				TypeException.throwUnnecessaryTypeChecking(@subject.type(), this)
			}
		}
		else if type.isClass() {
			if !@subject.type().isAny() && (!type.matchContentOf(@subject.type()) || type.matchClassName(@subject.type())) {
				TypeException.throwUnnecessaryTypeChecking(@subject.type(), this)
			}
		}
		else {
			TypeException.throwNotClass(variable.name(), this)
		}

		return type.reference()
	} // }}}
}