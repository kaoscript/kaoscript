class AssignmentOperatorEquals extends AssignmentOperatorExpression {
	private late {
		@assert: Boolean		= false
		@assertion				= null
		@condition: Boolean		= false
		@ignorable: Boolean		= false
		@lateinit: Boolean		= false
	}
	analyse() { # {{{
		@condition = @statement() is IfStatement

		super()
	} # }}}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		var rightType = @right.type().discardValue()
		var forcedFitting = @right is UnaryOperatorTypeFitting && @right.isForced()

		if @condition && @lateinit {
			@statement.initializeLateVariable(@left.name(), rightType, true)
		}
		else if !forcedFitting {
			@left.initializeVariables(rightType, this)
		}

		var leftType = @left.getDeclaredType().discardValue()

		if @isInDestructor() {
			@type = NullType.Explicit
		}
		else if forcedFitting {
			@type = leftType
		}
		else {
			unless rightType.isAssignableToVariable(leftType, true, false, false) {
				TypeException.throwInvalidAssignment(@left, leftType, rightType, this)
			}

			if !@isMisfit() && @parent is not BinaryOperatorTypeEquality | BinaryOperatorTypeInequality && !rightType.isDeferred() && !rightType.isFunction() && !rightType.isAssignableToVariable(leftType, false, false, false) {
				@assert = true
			}

			if @left.isInferable() {
				@type = leftType.tryCastingTo(rightType)
			}
			else {
				@type = rightType
			}
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		var split = @left.isSplitAssignment()

		if @assert && ?@left.toAssignmentFragments {
			@assertion = TempAssertExpression.new(@right, @type, this)
				..acquireReusable(split)
		}
		else {
			@right.acquireReusable(split)
		}
	} # }}}
	defineVariables(left) { # {{{
		if @condition {
			var names = []

			for var { name } in left.listAssignments([]) {
				if var variable ?= @scope.getVariable(name) {
					if variable.isLateInit() {
						throw NotImplementedException.new(this)
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
				isVariable: @left.isVariable()
				type: @type
			}
		}

		if @right is AssignmentOperatorEquals {
			@right.inferTypes(inferables)
		}

		return inferables
	} # }}}
	initializeVariable(variable: VariableBrief) { # {{{
		return @parent.initializeVariable(variable, this)
	} # }}}
	initializeVariable(variable: VariableBrief, expression: Expression) { # {{{
		return @parent.initializeVariable(variable, expression)
	} # }}}
	initializeVariables(type: Type, node: Expression)
	isAssigningBinding() => true
	isDeclarable() => @left.isDeclarable()
	isDeclararing() => true
	isIgnorable() => @ignorable
	releaseReusable() { # {{{
		(@assertion ?? @right).releaseReusable()
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @right.isAwaiting() {
			return @right.toFragments(fragments, mode)
		}
		else if @left.isUsingSetter() {
			@left.toSetterFragments(fragments, @right)
		}
		else if @assert {
			fragments.compile(@left).code($equals)

			@type.toAssertFragments(@right, fragments, this)
		}
		else {
			fragments.compile(@left).code($equals).compile(@right)
		}
	} # }}}
	toAssignmentFragments(fragments) { # {{{
		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @assertion ?? @right)
		}
		else if @assert {
			fragments.compile(@left).code($equals)

			@type.toAssertFragments(@right, fragments, this)
		}
		else {
			fragments.compile(@left).code($equals).compile(@right)
		}
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if @assert {
			fragments.compile(@left).code($equals)

			@type.toAssertFragments(@right, fragments, this)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}
	} # }}}
	toQuote() => `\(@left.toQuote()) = \(@right.toQuote())`
	type() => @parent is AssignmentOperatorEquals ? @type : Type.Void
	validate(target: Type) { # {{{
		if !target.isVoid() && @parent is not AssignmentOperatorEquals & MatchStatement {
			SyntaxException.throwNoReturn(this)
		}
	} # }}}
}

class AssignmentOperatorReturn extends AssignmentOperatorEquals {
	override isInferable() => @left.isInferable()
	override isVariable() => @left.isVariable()
	path() => @left.path()
	override validate(target)
	toQuote() => `\(@left.toQuote()) = \(@right.toQuote())`
	type() => @type
}
