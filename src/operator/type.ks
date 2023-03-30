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

		unless type.isAny() || type is ArrayType | ObjectType | ReferenceType | UnionType {
			TypeException.throwInvalidCasting(this)
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
		if @forced || @left.type().isAssignableToVariable(@type, false, false, false) {
			fragments.compile(@left)
		}
		else if !@nullable && @left.type().isAssignableToVariable(@type, false, true, false) {
			fragments.code($runtime.helper(this), '.notNull(').compile(@left).code(')')
		}
		else if @type.isAssignableToVariable(@left.type(), true, @nullable, true) {
			var type = @type.setNullable(false)

			fragments.code($runtime.helper(this), '.cast(').compile(@left).code($comma, type.toQuote(true), $comma, @nullable, $comma)

			type.toTestFunctionFragments(fragments, this)

			fragments.code(')')
		}
		else {
			TypeException.throwNotCastableTo(@left.type(), @type, this)
		}
	} # }}}
	type() => @type
}

class BinaryOperatorTypeEquality extends Expression {
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

			if @data.right.operator.kind == BinaryOperatorKind.And {
				type = new FusionType(@scope)

				@junction = Junction.AND
			}
			else {
				type = new UnionType(@scope)

				@junction = Junction.OR
			}

			for var operand in @data.right.operands {
				if operand.kind == NodeKind.TypeReference && operand.typeName?.kind == NodeKind.Identifier {
					if var variable ?= @scope.getVariable(operand.typeName.name) {
						type.addType(@validateType(variable))
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
			@computed = true

			@subject.acquireReusable(true)
			@subject.releaseReusable()
		}
		else {
			if @data.right.kind == NodeKind.TypeReference && @data.right.typeName?.kind == NodeKind.Identifier {
				if var variable ?= @scope.getVariable(@data.right.typeName.name) {
					@trueType = @validateType(variable)
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
		@trueType.toPositiveTestFragments(fragments, @subject)
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		@trueType.toPositiveTestFragments(fragments, @subject, junction)
	} # }}}
	type() => @scope.reference('Boolean')
	private validateType(variable: Variable) { # {{{
		var type = variable.getRealType()

		if @subject.type().isNull() {
			TypeException.throwNullTypeChecking(type, this)
		}

		if type.isVirtual() {
			if !@subject.type().isAny() && !@subject.type().canBeVirtual(type.name()) {
				TypeException.throwInvalidTypeChecking(@subject.type(), type, this)
			}
		}
		else if type.isClass() || type.isEnum() || type.isStruct() || type.isTuple() || type.isUnion() || type.isFusion() || type.isExclusion() {
			unless @scope.reference(type).isAssignableToVariable(@subject.type(), false, false, true) {
				TypeException.throwInvalidTypeChecking(@subject.type(), type, this)
			}
		}
		else {
			TypeException.throwNotClass(variable.name(), this)
		}

		return type.reference()
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

			if @data.right.operator.kind == BinaryOperatorKind.And {
				type = new FusionType(@scope)

				@junction = Junction.AND
			}
			else {
				type = new UnionType(@scope)

				@junction = Junction.OR
			}

			for var operand in @data.right.operands {
				if operand.kind == NodeKind.TypeReference && operand.typeName?.kind == NodeKind.Identifier {
					if var variable ?= @scope.getVariable(operand.typeName.name) {
						type.addType(@validateType(variable))
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
			@computed = true
		}
		else {
			if @data.right.kind == NodeKind.TypeReference && @data.right.typeName?.kind == NodeKind.Identifier {
				if var variable ?= @scope.getVariable(@data.right.typeName.name) {
					@falseType = @validateType(variable)
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
	private validateType(variable: Variable) { # {{{
		var type = variable.getRealType()

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
	} # }}}
}

class UnaryOperatorForcedTypeCasting extends UnaryOperatorExpression {
	private {
		@type: Type		= AnyType.Unexplicit
	}
	override prepare(target, targetMode) { # {{{
		super(target, targetMode)

		if !@parent.isExpectingType() {
			SyntaxException.throwInvalidForcedTypeCasting(this)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@argument)
	} # }}}
	type() => @type
}

class UnaryOperatorNullableTypeCasting extends UnaryOperatorExpression {
	private late {
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		super(target, targetMode)

		@type = @argument.type().setNullable(false)
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@argument)
	} # }}}
	type() => @type
}
