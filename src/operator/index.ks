enum AssignmentType {
	Declaration
	Expression
	Neither
	Parameter
}

enum OperandType {
	Any
	Bitmask
	Boolean
	Enum
	Number
	String
}

enum Operator<String> {
	Addition			= 'additive'
	BitwiseAnd			= 'bitwise-and'
	BitwiseLeftShift	= 'left-shift'
	BitwiseNegation		= 'bitwise-negation'
	BitwiseOr			= 'bitwise-or'
	BitwiseRightShift	= 'right-shift'
	BitwiseXor			= 'bitwise-xor'
	Division			= 'divisive'
	EmptyCoalescing		= 'empty-coalescing'
	GreaterThan			= 'greater-than'
	GreaterThanOrEqual	= 'greater-than-or-equal'
	LessThan			= 'less-than'
	LessThanOrEqual		= 'less-than-or-equal'
	LogicalAnd			= 'logical-and'
	LogicalImply		= 'logical-imply'
	LogicalNegation		= 'logical-negation'
	LogicalOr			= 'logical-or'
	LogicalXor			= 'logical-xor'
	Match				= 'match'
	Mismatch			= 'mismatch'
	Modulo				= 'modulo'
	Multiplication		= 'multiplicative'
	Negative			= 'negative'
	NullCoalescing		= 'null-coalescing'
	Pipeline			= 'pipeline'
	Quotient			= 'quotient'
	Subtraction			= 'subtractive'
}

var $operatorTypes = {
	[Operator.Addition]: ['Number']
	[Operator.BitwiseAnd]: ['Number']
	[Operator.BitwiseLeftShift]: ['Number']
	[Operator.BitwiseNegation]: ['Number']
	[Operator.BitwiseOr]: ['Number']
	[Operator.BitwiseRightShift]: ['Number']
	[Operator.BitwiseXor]: ['Number']
	[Operator.Division]: ['Number']
	[Operator.GreaterThan]: ['Number']
	[Operator.GreaterThanOrEqual]: ['Number']
	[Operator.LessThan]: ['Number']
	[Operator.LessThanOrEqual]: ['Number']
	[Operator.LogicalAnd]: ['Boolean']
	[Operator.LogicalImply]: ['Boolean']
	[Operator.LogicalNegation]: ['Boolean']
	[Operator.LogicalOr]: ['Boolean']
	[Operator.LogicalXor]: ['Boolean']
	[Operator.Modulo]: ['Number']
	[Operator.Multiplication]: ['Number']
	[Operator.Negative]: ['Number']
	[Operator.Quotient]: ['Number']
	[Operator.Subtraction]: ['Number']
}

include {
	'./assignment.ks'
	'./polyadic.ks'
	'./binary.ks'
	'./unary.ks'
	'./numeric.ks'
	'./bitwise.ks'
	'./comparison.ks'
	'./empty.ks'
	'./equals.ks'
	'./exists.ks'
	'./implicit.ks'
	'./logical.ks'
	'./pipeline.ks'
	'./type.ks'
}
