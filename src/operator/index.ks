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
	DivisionEuclidean	= 'euclidean-division'
	DivisionInteger		= 'integer-division'
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
	Modulus				= 'modulus'
	Multiplication		= 'multiplicative'
	Negative			= 'negative'
	NonFiniteCoalescing	= 'non-finite-coalescing'
	NullCoalescing		= 'null-coalescing'
	Pipeline			= 'pipeline'
	Power				= 'power'
	Remainder			= 'remainder'
	Subtraction			= 'subtractive'
	VariantCoalescing	= 'variant-coalescing'
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
	[Operator.DivisionEuclidean]: ['Number']
	[Operator.DivisionInteger]: ['Number']
	[Operator.GreaterThan]: ['Number']
	[Operator.GreaterThanOrEqual]: ['Number']
	[Operator.LessThan]: ['Number']
	[Operator.LessThanOrEqual]: ['Number']
	[Operator.LogicalAnd]: ['Boolean']
	[Operator.LogicalImply]: ['Boolean']
	[Operator.LogicalNegation]: ['Boolean']
	[Operator.LogicalOr]: ['Boolean']
	[Operator.LogicalXor]: ['Boolean']
	[Operator.Modulus]: ['Number']
	[Operator.Multiplication]: ['Number']
	[Operator.Negative]: ['Number']
	[Operator.Power]: ['Number']
	[Operator.Remainder]: ['Number']
	[Operator.Subtraction]: ['Number']
}

include {
	'./assignment.ks'
	'./polyadic.ks'
	'./binary.ks'
	'./unary.ks'
	'./arithmetic.ks'
	'./bitwise.ks'
	'./comparison.ks'
	'./empty.ks'
	'./equals.ks'
	'./exists.ks'
	'./finite.ks'
	'./implicit.ks'
	'./length.ks'
	'./logical.ks'
	'./pipeline.ks'
	'./type.ks'
	'./variant.ks'
}
