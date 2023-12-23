class BinaryOperatorExpression extends Expression {
	private {
		@await: Boolean		= false
		@left
		@right
		@tested: Boolean	= false
	}
	analyse() { # {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()

		@right = $compile.expression(@data.right, this)
		@right.analyse()

		@await = @left.isAwait() || @right.isAwait()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@left.prepare(target, targetMode)

		if @left.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		@right.prepare(target, targetMode)

		if @right.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@right, this)
		}
	} # }}}
	translate() { # {{{
		@left.translate()
		@right.translate()
	} # }}}
	acquireReusable(acquire) { # {{{
		@left.acquireReusable(false)
		@right.acquireReusable(false)
	} # }}}
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
	left(): valueof @left
	left(@left): valueof this
	listAssignments(array: Array) { # {{{
		@left.listAssignments(array)
		@right.listAssignments(array)

		return array
	} # }}}
	listNonLocalVariables(scope: Scope, variables: Array) { # {{{
		@left.listNonLocalVariables(scope, variables)
		@right.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	releaseReusable() { # {{{
		@left.releaseReusable()
		@right.releaseReusable()
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @await {
			if @left.isAwaiting() {
				return @left.toFragments(fragments, mode)
			}
			else if @right.isAwaiting() {
				return @right.toFragments(fragments, mode)
			}
			else {
				@toOperatorFragments(fragments)
			}
		}
		else if @isNullable() && !@tested {
			fragments
				.wrapNullable(this)
				.code(' ? ')

			@toOperatorFragments(fragments)

			fragments.code(' : false')
		}
		else {
			@toOperatorFragments(fragments)
		}
	} # }}}
	toNullableFragments(fragments) { # {{{
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
	} # }}}
}

class BinaryOperatorAddition extends BinaryOperatorExpression {
	private late {
		@bitmask: Boolean			= false
		@expectingBitmask: Boolean	= true
		@native: Boolean			= false
		@number: Boolean			= false
		@string: Boolean			= false
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		if !target.isVoid() && !target.canBeBitmask() {
			@expectingBitmask = false
		}

		if @left.type().isBitmask() && @right.type().isBitmask() && @left.type().discardValue().name() == @right.type().discardValue().name() {
			@bitmask = true

			if @expectingBitmask {
				@type = @left.type().discardValue()
			}
			else {
				@type = @left.type().discard().type()
			}

			@left.unflagExpectingBitmask()
			@right.unflagExpectingBitmask()
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
						TypeException.throwInvalidOperand(@right, Operator.Addition, this)
					}
				}
			}
			else {
				TypeException.throwInvalidOperand(@left, Operator.Addition, this)
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
				@type = UnionType.new(@scope, [@scope.reference('Number'), @scope.reference('String')])

				if nullable {
					@type = @type.setNullable(true)
				}
			}
		}
	} # }}}
	isComputed() => @native || (@bitmask && !@expectingBitmask)
	override path() => `\(@left.path()) + \(@right.path())`
	setOperands(@left, @right, @bitmask = false, @number = false, @expectingBitmask = false): valueof this
	toOperandFragments(fragments, operator, type) { # {{{
		if operator == Operator.Addition {
			if type == OperandType.Bitmask && @bitmask {
				fragments.wrap(@left).code(' | ').wrap(@right)
			}
			else if ((@number && type == OperandType.Number) || (@string && type == OperandType.String)) {
				fragments.compile(@left).code($comma).compile(@right)
			}
			else {
				this.toOperatorFragments(fragments)
			}
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} # }}}
	toOperatorFragments(fragments) { # {{{
		if @bitmask {
			if @expectingBitmask {
				fragments.code(@type.name(), '(').wrap(@left).code(' | ').wrap(@right).code(')')
			}
			else {
				fragments.wrap(@left).code(' | ').wrap(@right)
			}
		}
		else if @native {
			fragments
				.wrap(@left)
				.code($space)
				.code('+', @data.operator)
				.code($space)
				.wrap(@right)
		}
		else {
			if @number {
				fragments.code($runtime.operator(this), '.addNum(')
			}
			else if @string {
				fragments.code($runtime.helper(this), '.concatString(')
			}
			else {
				fragments.code($runtime.operator(this), '.add(')
			}

			fragments.compile(@left).code($comma).compile(@right).code(')')
		}
	} # }}}
	toQuote() => `\(@left.toQuote()) + \(@right.toQuote())`
	type() => @type
	unflagExpectingBitmask() { # {{{
		@expectingBitmask = false
	} # }}}
}

class BinaryOperatorMatch extends Expression {
	private late {
		@await: Boolean				= false
		@composite: Boolean			= false
		@native: Boolean			= true
		@junction: String
		@junctive: Boolean			= false
		@operands					= []
		@reuseName: String?			= null
		@subject
		@tested: Boolean			= false
	}
	analyse() { # {{{
		@subject = $compile.expression(@data.left, this)
		@subject.analyse()

		if @data.right.kind == NodeKind.JunctionExpression {
			@junctive = true

			for var operand in @data.right.operands {
				@addOperand(operand)
			}

			if @data.right.operator.kind == BinaryOperatorKind.JunctionAnd {
				@junction = ' && '
			}
			else if @data.right.operator.kind == BinaryOperatorKind.JunctionOr {
				@junction = ' || '
			}
		}
		else {
			@addOperand(@data.right)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@subject.prepare(AnyType.NullableUnexplicit)

		if @subject.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@subject, this)
		}

		unless @subject.type().canBeNumber() {
			TypeException.throwInvalidOperand(@subject, Operator.Match, this)
		}

		if !@subject.type().isNumber() {
			@native = false
		}

		for var operand in @operands {
			operand.prepare(AnyType.NullableUnexplicit)

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			unless operand.type().canBeNumber() {
				TypeException.throwInvalidOperand(operand, Operator.Match, this)
			}
		}
	} # }}}
	translate() { # {{{
		@subject.translate()

		for var operand in @operands {
			operand.translate()
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		if @junctive && @subject.isComposite() {
			@composite = true

			@reuseName = @scope.acquireTempName()
		}

		@subject.acquireReusable(acquire)

		for var operand in @operands {
			operand.acquireReusable(acquire)
		}
	} # }}}
	private addOperand(data) { # {{{
		var operand = $compile.expression(data, this)

		operand.analyse()

		@operands.push(operand)

		if operand.isAwait() {
			@await = true
		}
	} # }}}
	inferTypes(inferables) => @subject.inferTypes(inferables)
	isComputed() => true
	operator() => '!='
	releaseReusable() { # {{{
		if @composite {
			@scope.releaseTempName(@reuseName)
		}

		@subject.releaseReusable()

		for var operand in @operands {
			operand.releaseReusable()
		}
	} # }}}
	subject() => @subject
	toFragments(fragments, mode) { # {{{
		if @await {
			NotSupportedException.throw(this)
		}

		var test = @isNullable() && !@tested
		if test {
			fragments.wrapNullable(this).code(' ? ')
		}

		if @junctive {
			if !?@junction {
				fragments.code($runtime.operator(this), '.xor(')

				this.toOperatorFragments(fragments, @operands[0], true)

				for var operand in @operands from 1 {
					fragments.code($comma)

					this.toOperatorFragments(fragments, operand, false)
				}

				fragments.code(')')
			}
			else {
				this.toOperatorFragments(fragments, @operands[0], true)

				for var operand in @operands from 1 {
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
	} # }}}
	toNullableFragments(fragments) { # {{{
		if !@tested {
			var mut nf = false

			if @subject.isNullable() {
				nf = true

				fragments.compileNullable(@subject)
			}

			for var operand in @operands {
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
	} # }}}
	toOperatorFragments(fragments, operand, assignable) { # {{{
		var native = @native && operand.type().isNumber() && !operand.type().isNullable()
		var operator = this.operator()

		if @composite {
			if assignable {
				if native {
					fragments.code(`((\(@reuseName) = `).compile(@subject).code(') & ').wrap(operand).code(`) \(operator) 0`)
				}
				else {
					fragments
						.code($runtime.operator(this), `.bitAnd(\(@reuseName) = `)
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
					fragments.code($runtime.operator(this), `.bitAnd(\(@reuseName), `).compile(operand).code(`) \(operator) 0`)
				}
			}
		}
		else {
			if native {
				fragments.code('(').wrap(@subject).code(' & ').wrap(operand).code(`) \(operator) 0`)
			}
			else {
				fragments
					.code($runtime.operator(this), `.bitAnd(`)
					.compile(@subject)
					.code($comma)
					.compile(operand)
					.code(`) \(operator) 0`)
			}
		}
	} # }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorMismatch extends BinaryOperatorMatch {
	operator() => '=='
}
