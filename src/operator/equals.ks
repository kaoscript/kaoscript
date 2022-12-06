class AssignmentOperatorEquals extends AssignmentOperatorExpression {
	private late {
		@condition: Boolean		= false
		@ignorable: Boolean		= false
		@lateinit: Boolean		= false
	}
	analyse() { # {{{
		@condition = @statement() is IfStatement

		super()
	} # }}}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode::Permissive)

		if @condition && @lateinit {
			@statement.initializeLateVariable(@left.name(), @right.type(), true)
		}
		else {
			@left.initializeVariables(@right.type(), this)
		}

		@type = @left.getDeclaredType()

		if @isInDestructor() {
			@type = NullType.Explicit
		}
		else {
			unless @right.type().isAssignableToVariable(@type, true, false, false) {
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
				if var variable ?= @scope.getVariable(name) {
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

		if @right is AssignmentOperatorEquals {
			@right.inferTypes(inferables)
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

		while ?parent {
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
		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).compile(@right)
		}
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		fragments.compile(@left).code($equals).wrap(@right)
	} # }}}
	toQuote() => `\(@left.toQuote()) = \(@right.toQuote())`
	type() => @type
	validate(target: Type) { # {{{
		if !target.isVoid() && @parent is not AssignmentOperatorEquals {
			SyntaxException.throwNoReturn(this)
		}
	} # }}}
}

class AssignmentOperatorReturn extends AssignmentOperatorEquals {
	override validate(target)
	toQuote() => `\(@left.toQuote()) = \(@right.toQuote())`
}
