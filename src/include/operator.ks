enum AssignmentType {
	Declaration
	Expression
	Neither
	Parameter
}

enum OperandType {
	Any
	Boolean
	Enum
	Number
	String
}

enum Operator<String> {
	Addition			= 'additive'
	And					= 'and'
	DecrementPostfix	= 'postfix-decrement'
	DecrementPrefix		= 'prefix-decrement'
	Division			= 'divisive'
	GreaterThan			= 'greater-than'
	GreaterThanOrEqual	= 'greater-than-or-equal'
	Imply				= 'imply'
	IncrementPostfix	= 'postfix-increment'
	IncrementPrefix		= 'prefix-increment'
	LeftShift			= 'left-shift'
	LessThan			= 'less-than'
	LessThanOrEqual		= 'less-than-or-equal'
	Match				= 'match'
	Mismatch			= 'mismatch'
	Modulo				= 'modulo'
	Multiplication		= 'multiplicative'
	Negation			= 'negation'
	Negative			= 'negative'
	NullCoalescing		= 'null-coalescing'
	Or					= 'or'
	Quotient			= 'quotient'
	RightShift			= 'right-shift'
	Subtraction			= 'subtractive'
	Xor					= 'xor'
}

var $operatorTypes = {
	[Operator::Addition]: ['Number']
	[Operator::And]: ['Boolean', 'Number']
	[Operator::DecrementPostfix]: ['Number']
	[Operator::DecrementPrefix]: ['Number']
	[Operator::Division]: ['Number']
	[Operator::GreaterThan]: ['Number']
	[Operator::GreaterThanOrEqual]: ['Number']
	[Operator::Imply]: ['Boolean']
	[Operator::IncrementPostfix]: ['Number']
	[Operator::IncrementPrefix]: ['Number']
	[Operator::LeftShift]: ['Number']
	[Operator::LessThan]: ['Number']
	[Operator::LessThanOrEqual]: ['Number']
	[Operator::Modulo]: ['Number']
	[Operator::Multiplication]: ['Number']
	[Operator::Negation]: ['Boolean', 'Number']
	[Operator::Negative]: ['Number']
	[Operator::Or]: ['Boolean', 'Number']
	[Operator::Quotient]: ['Number']
	[Operator::RightShift]: ['Number']
	[Operator::Subtraction]: ['Number']
	[Operator::Xor]: ['Boolean', 'Number']
}

include {
	'../operator/assignment'
	'../operator/polyadic'
	'../operator/binary'
	'../operator/unary'
	'../operator/comparison'
	'../operator/logical'
}
