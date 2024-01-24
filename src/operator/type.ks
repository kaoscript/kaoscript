class BinaryOperatorTypeAssertion extends Expression {
	private late {
		@left: Expression
		@nullable: Boolean		= false
		@reusable: Boolean		= false
		@reuseName: String?
		@right: Type
		@toAssert: Boolean		= false
		@toEnum: Boolean		= false
		@toNonNull: Boolean		= false
		@toRawValue: Boolean	= false
		@type: Type
	}
	override analyse() { # {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()

		@type = @right = Type.fromAST(@data.right, this)

		for var modifier in @data.operator.modifiers {
			if modifier.kind == ModifierKind.Nullable {
				@nullable = true

				@type = @type.setNullable(true)
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@left.prepare(AnyType.NullableUnexplicit)

		var type = @left.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		if type.isAny() {
			@toAssert = true
		}
		else if type is not ArrayType & ObjectType & ReferenceType & UnionType {
			TypeException.throwInvalidCasting(this)
		}
		else if @right.isEnum() {
			unless @right.discard().type().isAssignableToVariable(type, true, @nullable, false) {
				TypeException.throwNotCastableTo(type, @right, this)
			}

			@toEnum = true
		}
		else if !type.isAssignableToVariable(@right, true, @nullable, false) {
			if type.isAssignableToVariable(@right, true, true, false) {
				@toNonNull = true
			}
			else if @right.isAssignableToVariable(type, true, @nullable, false) || type.isSubsetOf(@right, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
				@toAssert = true
			}
			else {
				TypeException.throwNotCastableTo(type, @right, this)
			}
		}
	} # }}}
	override translate() { # {{{
		@left.translate()
	} # }}}
	acquireReusable(acquire) { # {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}
	} # }}}
	expression() => @left
	isLooseComposite() => @toAssert || @toEnum || @toNonNull || @toRawValue
	listAssignments(array) => @left.listAssignments(array)
	name() => @left is IdentifierLiteral ? @left.name() : null
	releaseReusable() { # {{{
		if ?@reuseName {
			@scope.releaseTempName(@reuseName)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else if @toEnum {
			if @nullable {
				fragments.compile(@right).code('(').compile(@left).code(')')
			}
			else {
				fragments.code(`\($runtime.helper(this)).notNull(`).compile(@right).code('(').compile(@left).code('))')
			}
		}
		else if @toNonNull {
			fragments.code(`\($runtime.helper(this)).notNull(`).compile(@left).code(')')
		}
		else if @toRawValue {
			fragments.compile(@left).code('.value')
		}
		else if @toAssert {
			@right.toAssertFunctionFragments(@left, @nullable, fragments, this)
		}
		else {
			fragments.compile(@left)
		}
	} # }}}
	override toQuote() { # {{{
		return `\(@left.toQuote()):&\(@nullable ? '?' : '')(\(@right.toQuote()))`
	} # }}}
	toReusableFragments(fragments) { # {{{
		fragments.code(`\(@reuseName) = `).compile(this)

		@reusable = true
	} # }}}
	type() => @type

	proxy @left {
		hasExceptions
		inferTypes
		isNullable
		isUsingVariable
		isUsingInstanceVariable
	}
}

class BinaryOperatorTypeCasting extends Expression {
	private late {
		@left: Expression
		@nullable: Boolean		= false
		@reusable: Boolean		= false
		@reuseName: String?
		@right: Type
		@toCasting: Boolean		= false
		@toEnum: Boolean		= false
		@toNonNull: Boolean		= false
		@toRawValue: Boolean	= false
		@type: Type
	}
	analyse() { # {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()

		@type = @right = Type.fromAST(@data.right, this)

		for var modifier in @data.operator.modifiers {
			if modifier.kind == ModifierKind.Nullable {
				@nullable = true

				@type = @type.setNullable(true)
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@left.prepare(AnyType.NullableUnexplicit)

		var type = @left.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		if type.isAny() {
			@toCasting = true
		}
		else if type is not ArrayType & ObjectType & ReferenceType & UnionType {
			TypeException.throwInvalidCasting(this)
		}
		else if @right.isEnum() {
			unless @right.discard().type().isAssignableToVariable(type, true, @nullable, false) {
				TypeException.throwNotCastableTo(type, @right, this)
			}

			@toEnum = true
		}
		else if type.isEnum() {
			unless @right.isAssignableToVariable(type.discard().type(), true, @nullable, false) {
				TypeException.throwNotCastableTo(type, @right, this)
			}

			@toRawValue = true
		}
		else if !type.isAssignableToVariable(@right, true, @nullable, false) {
			if type.isAssignableToVariable(@right, true, true, false) {
				@toNonNull = true
			}
			else if @right.isSubsetOf(type, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.TypeCasting) {
				@toCasting = true
			}
			else {
				TypeException.throwNotCastableTo(type, @right, this)
			}
		}
	} # }}}
	translate() { # {{{
		@left.translate()
	} # }}}
	acquireReusable(acquire) { # {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}
	} # }}}
	expression() => @left
	hasExceptions() => false
	inferTypes(inferables) => @left.inferTypes(inferables)
	isNullable() => @left.isNullable()
	isLooseComposite() => @toCasting || @toEnum || @toNonNull || @toRawValue
	isUsingVariable(name) => @left.isUsingVariable(name)
	isUsingInstanceVariable(name) => @left.isUsingInstanceVariable(name)
	listAssignments(array: Array) => @left.listAssignments(array)
	name() => @left is IdentifierLiteral ? @left.name() : null
	releaseReusable() { # {{{
		if ?@reuseName {
			@scope.releaseTempName(@reuseName)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else if @toEnum {
			if @nullable {
				fragments.compile(@right).code('(').compile(@left).code(')')
			}
			else {
				fragments.code(`\($runtime.helper(this)).notNull(`).compile(@right).code('(').compile(@left).code('))')
			}
		}
		else if @toNonNull {
			fragments.code(`\($runtime.helper(this)).notNull(`).compile(@left).code(')')
		}
		else if @toRawValue {
			fragments.compile(@left).code('.value')
		}
		else if @toCasting {
			@right.toCastFunctionFragments(@left, @nullable, fragments, this)
		}
		else {
			fragments.compile(@left)
		}
	} # }}}
	toQuote() { # {{{
		return `\(@left.toQuote()):>\(@nullable ? '?' : '')(\(@right.toQuote()))`
	} # }}}
	toReusableFragments(fragments) { # {{{
		fragments.code(`\(@reuseName) = `).compile(this)

		@reusable = true
	} # }}}
	type() => @type
}

class BinaryOperatorTypeEquality extends Expression {
	private late {
		@computed: Boolean		= false
		@falseType: Type
		@junction: Junction		= Junction.NONE
		@subject
		@testNullable: Boolean	= false
		@testType: Type
		@trueType: Type
	}
	analyse() { # {{{
		@subject = $compile.expression(@data.left, this)
		@subject.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@subject.prepare(AnyType.NullableUnexplicit)

		var subjectType = @subject.type()

		if subjectType.isInoperative() {
			TypeException.throwUnexpectedInoperative(@subject, this)
		}

		if @data.right.kind == NodeKind.JunctionExpression {
			var late type: Type

			if @data.right.operator.kind == BinaryOperatorKind.JunctionAnd {
				type = FusionType.new(@scope)

				@junction = Junction.AND
			}
			else {
				type = UnionType.new(@scope)

				@junction = Junction.OR
			}

			for var operand in @data.right.operands {
				type.addType(@confirmType(Type.fromAST(operand, subjectType, this)))
			}

			@testType = type.type()
			@computed = true

			@subject.acquireReusable(true)
			@subject.releaseReusable()
		}
		else {
			@testType = @confirmType(Type.fromAST(@data.right, subjectType, this))
		}

		if @subject.isInferable() {
			@trueType = subjectType.limitTo(@testType)
			@falseType = subjectType.trimOff(@trueType)
		}

		@testNullable = @subject.isNullable()
	} # }}}
	translate() { # {{{
		@subject.translate()
	} # }}}
	hasExceptions() => false
	inferTypes(inferables) { # {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject.isVariable()
				type: @subject.type()
			}
		}

		return inferables
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject.isVariable()
				isTyping: true
				type: @trueType
			}

			@subject.inferProperty(@trueType, inferables)
		}

		return inferables
	} # }}}
	inferWhenFalseTypes(inferables) { # {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject.isVariable()
				type: @falseType
			}

			@subject.inferProperty(@falseType, inferables)
		}

		return inferables
	} # }}}
	isBooleanComputed(junction: Junction) => @testNullable || (@computed && junction != @junction) || @testType.isVariant()
	isComputed() => @testNullable
	isNullable() => false
	isUsingVariable(name) => @subject.isUsingVariable(name)
	isUsingInstanceVariable(name) => @subject.isUsingInstanceVariable(name)
	listAssignments(array: Array) => @subject.listAssignments(array)
	toFragments(fragments, mode) { # {{{
		@testType.toPositiveTestFragments(fragments, @subject)
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if @testNullable {
			fragments.wrapNullable(@subject).code(' ? ')
		}

		var type = @subject.type()

		if type is ReferenceType {
			@testType.toPositiveTestFragments(type.parameters(), type.getSubtypes(), junction, fragments, @subject)
		}
		else {
			@testType.toPositiveTestFragments(null, null, junction, fragments, @subject)
		}

		if @testNullable {
			fragments.code(' : false')
		}
	} # }}}
	type() => @scope.reference('Boolean')
	private confirmType(type: Type): Type { # {{{
		var subjectType = @subject.type()

		if subjectType.isNull() {
			TypeException.throwNullTypeChecking(type, this)
		}

		if type.isVirtual() {
			if !subjectType.isAny() && !subjectType.canBeVirtual(type.name()) {
				TypeException.throwInvalidTypeChecking(@subject, type, this)
			}
		}
		else {
			if subjectType.isSubsetOf(type, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
				TypeException.throwUnnecessaryTypeChecking(@subject, type, this)
			}

			unless type.isAssignableToVariable(subjectType, false, false, true) {
				TypeException.throwInvalidTypeChecking(@subject, type, this)
			}
		}

		return type
	} # }}}
}

class BinaryOperatorTypeInequality extends Expression {
	private late {
		@computed: Boolean		= false
		@falseType: Type
		@junction: Junction		= Junction.NONE
		@subject
		@trueType: Type
	}
	analyse() { # {{{
		@subject = $compile.expression(@data.left, this)
		@subject.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@subject.prepare(AnyType.NullableUnexplicit)

		if @subject.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@subject, this)
		}

		if @data.right.kind == NodeKind.JunctionExpression {
			var late type: Type

			if @data.right.operator.kind == BinaryOperatorKind.JunctionAnd {
				type = FusionType.new(@scope)

				@junction = Junction.AND
			}
			else {
				type = UnionType.new(@scope)

				@junction = Junction.OR
			}

			for var operand in @data.right.operands {
				type.addType(@confirmType(Type.fromAST(operand, @subject.type(), this)))
			}

			@falseType = type.type()
			@computed = true

			@subject.acquireReusable(true)
			@subject.releaseReusable()
		}
		else {
			@falseType = @confirmType(Type.fromAST(@data.right, @subject.type(), this))
		}

		if @subject.isInferable() {
			@trueType = @subject.type().trimOff(@falseType)
		}
	} # }}}
	translate() { # {{{
		@subject.translate()
	} # }}}
	hasExceptions() => false
	inferTypes(inferables) => @subject.inferTypes(inferables)
	isBooleanComputed(junction: Junction) => @computed && junction != @junction
	isComputed() => false
	isNullable() => false
	isUsingVariable(name) => @subject.isUsingVariable(name)
	isUsingInstanceVariable(name) => @subject.isUsingInstanceVariable(name)
	inferWhenTrueTypes(inferables) { # {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject.isVariable()
				isTyping: true
				type: @trueType
			}
		}

		return inferables
	} # }}}
	inferWhenFalseTypes(inferables) { # {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject.isVariable()
				type: @falseType
			}
		}

		return inferables
	} # }}}
	listAssignments(array: Array) => @subject.listAssignments(array)
	toFragments(fragments, mode) { # {{{
		@falseType.toNegativeTestFragments(fragments, @subject)
	} # }}}
	type() => @scope.reference('Boolean')
	private confirmType(type: Type): Type { # {{{
		var subjectType = @subject.type()

		if subjectType.isNull() {
			TypeException.throwNullTypeChecking(type, this)
		}

		if type.isVirtual() {
			if !subjectType.isAny() && !subjectType.canBeVirtual(type.name()) {
				TypeException.throwInvalidTypeChecking(@subject, type, this)
			}
		}
		else {
			if subjectType.isSubsetOf(type, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
				TypeException.throwUnnecessaryTypeChecking(@subject, type, this)
			}

			unless type.isAssignableToVariable(subjectType, false, false, true) {
				TypeException.throwInvalidTypeChecking(@subject, type, this)
			}
		}

		return type
	} # }}}
}

class UnaryOperatorTypeFitting extends UnaryOperatorExpression {
	private {
		@forced: Boolean	= false
		@type: Type			= AnyType.Unexplicit
	}
	override analyse() { # {{{
		super()

		for var modifier in @data.modifiers {
			match modifier.kind {
				ModifierKind.Forced {
					@forced = true
				}
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		super(target, targetMode)

		if @forced {
			if !@parent.isExpectingType() {
				SyntaxException.throwInvalidForcedTypeCasting(this)
			}
		}
		else {
			@type = @argument.type().setNullable(false)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@argument)
	} # }}}
	type() => @type
}

class BinaryOperatorTypeSignalment extends Expression {
	private late {
		@forced: Boolean	= false
		@left: Expression
		@type: Type
	}
	override analyse() { # {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()

		@type = Type.fromAST(@data.right, this)

		for var modifier in @data.operator.modifiers {
			if modifier.kind == ModifierKind.Forced {
				@forced = true
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@left.prepare(AnyType.NullableUnexplicit)

		var type = @left.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		if @forced || type.isAny() {
			pass
		}
		else if !type.isAssignableToVariable(@type, true, true, true) {
			TypeException.throwNotRetypeableTo(type, @type, this)
		}
	} # }}}
	override translate() { # {{{
		@left.translate()
	} # }}}
	expression() => @left
	listAssignments(array) => @left.listAssignments(array)
	name() => @left.name()
	override toQuote() { # {{{
		if @forced {
			return `\(@left.toQuote()):!!(\(@type.toQuote()))`
		}
		else {
			return `\(@left.toQuote()):!(\(@type.toQuote()))`
		}
	} # }}}
	type() => @type

	proxy @left {
		acquireReusable
		hasExceptions
		isComputed
		isNullable
		isUsingVariable
		isUsingInstanceVariable
		releaseReusable
		toFragments
	}
}
