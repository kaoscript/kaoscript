class BinaryOperatorTypeCasting extends Expression {
	private late {
		@forced: Boolean	= false
		@left
		@nullable: Boolean	= false
		@type: Type
	}
	analyse() { # {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()

		@type = Type.fromAST(@data.right, this)

		for var modifier in @data.operator.modifiers {
			if modifier.kind == ModifierKind.Forced {
				@forced = true
			}
			else if modifier.kind == ModifierKind.Nullable {
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

		if @forced || type.isAny() {
			pass
		}
		else if type is not ArrayType & ObjectType & ReferenceType & UnionType {
			TypeException.throwInvalidCasting(this)
		}
		else if @type.isEnum() {
			unless @type.discard().type().isAssignableToVariable(type, true, true, true) {
				TypeException.throwNotCastableTo(type, @type, this)
			}
		}
		else if type.isEnum() {
			unless @type.isAssignableToVariable(type.discard().type(), true, true, true) {
				TypeException.throwNotCastableTo(type, @type, this)
			}
		}
		else if !type.isAssignableToVariable(@type, true, true, true) {
			TypeException.throwNotCastableTo(type, @type, this)
		}
	} # }}}
	translate() { # {{{
		@left.translate()
	} # }}}
	hasExceptions() => false
	inferTypes(inferables) => @left.inferTypes(inferables)
	isComputed() => false
	isNullable() => @left.isNullable()
	isUsingVariable(name) => @left.isUsingVariable(name)
	isUsingInstanceVariable(name) => @left.isUsingInstanceVariable(name)
	listAssignments(array: Array) => @left.listAssignments(array)
	name() => @left is IdentifierLiteral ? @left.name() : null
	toFragments(fragments, mode) { # {{{
		if @type.isEnum() {
			var type = @type.setNullable(false)

			if @nullable {
				fragments.compile(type).code('(').compile(@left).code(')')
			}
			else {
				fragments.code(`\($runtime.helper(this)).notNull(`).compile(type).code('(').compile(@left).code('))')
			}
		}
		else if @forced || @left.type().isAssignableToVariable(@type, false, false, false) {
			fragments.compile(@left)
		}
		else if !@nullable && @left.type().isAssignableToVariable(@type, false, true, false) {
			fragments.code(`\($runtime.helper(this)).notNull(`).compile(@left).code(')')
		}
		else if @left.type().isEnum() {
			fragments.compile(@left).code('.value')
		}
		else if @type.isObject() && @type.canBeRawCasted() {
			var type = @type.discard()

			type.toCastFragments(fragments, @left)

			fragments.code(' ? ').compile(@left).code(' : null')
		}
		else if @type.isAssignableToVariable(@left.type(), true, @nullable, true) {
			var type = @type.setNullable(false)

			fragments.code($runtime.helper(this), '.cast(').compile(@left).code($comma, type.toQuote(true), $comma, @nullable, $comma)

			type.toBlindTestFunctionFragments(null, 'value', false, true, null, fragments, this)

			fragments.code(')')
		}
		else {
			TypeException.throwNotCastableTo(@left.type(), @type, this)
		}
	} # }}}
	toQuote() { # {{{
		if @forced {
			return `\(@left.toQuote()) as! \(@type.toQuote())`
		}
		if @nullable {
			return `\(@left.toQuote()) as? \(@type.setNullable(false).toQuote())`
		}

		return `\(@left.toQuote()) as \(@type.toQuote())`
	} # }}}
	type() => @type
}

class BinaryOperatorTypeEquality extends Expression {
	private late {
		@computed: Boolean		= false
		@falseType: Type
		@junction: Junction		= Junction.NONE
		@subject
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
	} # }}}
	translate() { # {{{
		@subject.translate()
	} # }}}
	hasExceptions() => false
	inferWhenTrueTypes(inferables) { # {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject is IdentifierLiteral
				isTyping: true
				type: @trueType
			}
		}

		return inferables
	} # }}}
	inferWhenFalseTypes(inferables) { # {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject is IdentifierLiteral
				type: @falseType
			}
		}

		return inferables
	} # }}}
	isBooleanComputed(junction: Junction) => @computed && junction != @junction
	isComputed() => false
	isNullable() => false
	isUsingVariable(name) => @subject.isUsingVariable(name)
	isUsingInstanceVariable(name) => @subject.isUsingInstanceVariable(name)
	listAssignments(array: Array) => @subject.listAssignments(array)
	toFragments(fragments, mode) { # {{{
		@testType.toPositiveTestFragments(fragments, @subject)
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		var type = @subject.type()

		if type is ReferenceType {
			@testType.toPositiveTestFragments(type.parameters(), type.getSubtypes(), junction, fragments, @subject)
		}
		else {
			@testType.toPositiveTestFragments(null, null, junction, fragments, @subject)
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
			if subjectType.isSubsetOf(type, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast) {
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
				isVariable: @subject is IdentifierLiteral
				isTyping: true
				type: @trueType
			}
		}

		return inferables
	} # }}}
	inferWhenFalseTypes(inferables) { # {{{
		if @subject.isInferable() {
			inferables[@subject.path()] = {
				isVariable: @subject is IdentifierLiteral
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
			if subjectType.isSubsetOf(type, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast) {
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
