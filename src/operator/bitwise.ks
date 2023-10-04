class PolyadicOperatorBitwiseAnd extends NumericPolyadicOperatorExpression {
	isAcceptingEnum() => true
	native() => '&'
	operator() => Operator.BitwiseAnd
	runtime() => 'bitAnd'
	symbol() => '+&'
}

class PolyadicOperatorBitwiseOr extends NumericPolyadicOperatorExpression {
	isAcceptingEnum() => true
	native() => '|'
	operator() => Operator.BitwiseOr
	runtime() => 'bitOr'
	symbol() => '+|'
}

class PolyadicOperatorBitwiseXor extends NumericPolyadicOperatorExpression {
	native() => '^'
	operator() => Operator.BitwiseXor
	runtime() => 'bitXor'
	symbol() => '+^'
}

abstract class BitwiseAssignmentOperatorExpression extends AssignmentOperatorExpression {
	private late {
		@native: Boolean		= true
	}
	abstract {
		native(): String
		operator(): Operator
		runtime(): String
		symbol(): String
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		var mut nullable = false

		if @type.isNumber() {
			if @type.isNullable() {
				nullable = true
				@native = false
			}
		}
		else if @type.isNull() {
			nullable = true
		}
		else if @type.canBeNumber() {
			if @type.isNullable() {
				nullable = true
			}

			@native = false
		}
		else {
			TypeException.throwInvalidOperation(this, this.operator(), this)
		}

		@type = @scope.reference('Number')

		if nullable {
			@type = @type.setNullable(true)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		var mut next = true

		if next && @native {
			next = @toNativeFragments(fragments)
		}

		if next {
			fragments
				.compileReusable(@left)
				.code(' = ')
				.code($runtime.operator(this), `.bit\(@runtime())(`)
				.compileReusable(@left)
				.code($comma)
				.compile(@right)
				.code(')')
		}
	} # }}}
	toNativeFragments(fragments) { # {{{
		fragments.compile(@left).code($space).code(@native(), @data.operator).code($space).compile(@right)
	} # }}}
	toQuote() => `\(@left.toQuote()) \(@symbol()) \(@right.toQuote())`
}

class AssignmentOperatorBitwiseAnd extends BitwiseAssignmentOperatorExpression {
	native() => '&='
	operator() => Operator.BitwiseAnd
	runtime() => 'And'
	symbol() => '+&='
}

class AssignmentOperatorBitwiseOr extends BitwiseAssignmentOperatorExpression {
	native() => '|='
	operator() => Operator.BitwiseOr
	runtime() => 'Or'
	symbol() => '+|='
}

class AssignmentOperatorBitwiseXor extends BitwiseAssignmentOperatorExpression {
	native() => '^='
	operator() => Operator.BitwiseXor
	runtime() => 'Xor'
	symbol() => '+^='
	toNativeFragments(fragments) { # {{{
		fragments.compile(@left).code($space).code(@native(), @data.operator).code($space).compile(@right)
	} # }}}
}

class PolyadicOperatorBitwiseLeftShift extends NumericPolyadicOperatorExpression {
	native() => '<<'
	operator() => Operator.BitwiseLeftShift
	runtime() => 'bitLeft'
	symbol() => '+<'
}

class AssignmentOperatorBitwiseLeftShift extends NumericAssignmentOperatorExpression {
	native() => '<<='
	operator() => Operator.BitwiseLeftShift
	runtime() => 'bitLeft'
	symbol() => '+<='
}

class PolyadicOperatorBitwiseRightShift extends NumericPolyadicOperatorExpression {
	native() => '>>'
	operator() => Operator.BitwiseRightShift
	runtime() => 'bitRight'
	symbol() => '+>'
}

class AssignmentOperatorBitwiseRightShift extends NumericAssignmentOperatorExpression {
	native() => '>>='
	operator() => Operator.BitwiseRightShift
	runtime() => 'bitRight'
	symbol() => '+>='
}

class UnaryOperatorBitwiseNegation extends UnaryOperatorExpression {
	private late {
		@native: Boolean		= true
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		if target.isVoid() {
			SyntaxException.throwDeadCode(this)
		}

		if !target.canBeNumber() {
			TypeException.throwInvalidOperation(this, Operator.LogicalNegation, this)
		}

		var mut nullable = false

		var type = @argument.type()

		if type.isNumber() {
			if type.isNullable() {
				nullable = true
				@native = false
			}
		}
		else if type.canBeNumber() {
			if type.isNullable() {
				nullable = true
			}

			@native = false
		}
		else {
			TypeException.throwInvalidOperand(@argument, Operator.BitwiseNegation, this)
		}

		@type = @scope.reference('Number')

		if nullable {
			@type = @type.setNullable(true)
		}
	} # }}}
	inferWhenFalseTypes(inferables) => @argument.inferWhenTrueTypes(inferables)
	inferWhenTrueTypes(inferables) => @argument.inferWhenFalseTypes(inferables)
	toFragments(fragments, mode) { # {{{
		if @native {
			fragments.code('~', @data.operator).compile(@argument)
		}
		else {
			fragments
				.code(`\($runtime.operator(this)).bitNeg(`)
				.compile(@argument)
				.code(')')
		}
	} # }}}
	type(): valueof @type
}
