enum AssignmentType {
	Declaration
	Expression
	Neither
	Parameter
}

enum OperandType {
	Any
	Enum
	Number
	String
}

enum Operator<String> {
	Addition			= 'additive'
	And					= 'and'
	BitwiseAnd			= 'bitwise-and'
	BitwiseLeftShift	= 'bitwise-left-shift'
	BitwiseNot			= 'bitwise-not'
	BitwiseOr			= 'bitwise-or'
	BitwiseRightShift	= 'bitwise-right-shift'
	BitwiseXor			= 'bitwise-xor'
	DecrementPostfix	= 'postfix-decrement'
	DecrementPrefix		= 'prefix-decrement'
	Division			= 'divisive'
	GreaterThan			= 'greater-than'
	GreaterThanOrEqual	= 'greater-than-or-equal'
	Imply				= 'imply'
	IncrementPostfix	= 'postfix-increment'
	IncrementPrefix		= 'prefix-increment'
	LessThan			= 'less-than'
	LessThanOrEqual		= 'less-than-or-equal'
	Match				= 'match'
	Mismatch			= 'mismatch'
	Modulo				= 'modulo'
	Multiplication		= 'multiplicative'
	Negation			= 'negation'
	Negative			= 'negative'
	Or					= 'or'
	Quotient			= 'quotient'
	Subtraction			= 'subtractive'
	Xor					= 'xor'
}

var $operatorTypes = {
	[Operator::Addition]: ['Number']
	[Operator::And]: ['Boolean']
	[Operator::BitwiseAnd]: ['Number']
	[Operator::BitwiseLeftShift]: ['Number']
	[Operator::BitwiseNot]: ['Number']
	[Operator::BitwiseOr]: ['Number']
	[Operator::BitwiseRightShift]: ['Number']
	[Operator::BitwiseXor]: ['Number']
	[Operator::DecrementPostfix]: ['Number']
	[Operator::DecrementPrefix]: ['Number']
	[Operator::Division]: ['Number']
	[Operator::GreaterThan]: ['Number']
	[Operator::GreaterThanOrEqual]: ['Number']
	[Operator::Imply]: ['Boolean']
	[Operator::IncrementPostfix]: ['Number']
	[Operator::IncrementPrefix]: ['Number']
	[Operator::LessThan]: ['Number']
	[Operator::LessThanOrEqual]: ['Number']
	[Operator::Modulo]: ['Number']
	[Operator::Multiplication]: ['Number']
	[Operator::Negation]: ['Boolean']
	[Operator::Negative]: ['Number']
	[Operator::Or]: ['Boolean']
	[Operator::Quotient]: ['Number']
	[Operator::Subtraction]: ['Number']
	[Operator::Xor]: ['Boolean']
}

include {
	'../operator/assignment'
	'../operator/polyadic'
	'../operator/binary'
	'../operator/unary'
	'../operator/comparison'
	'../operator/logical'
}
