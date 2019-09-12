enum AssignmentType {
	Declaration
	Expression
	Neither
	Parameter
}

enum OperandType {
	Any
	Number
	String
}

enum Operator<String> {
	Addition
	And
	BitwiseAnd			= 'bitwise-and'
	BitwiseLeftShift	= 'bitwise-left-shift'
	BitwiseNot			= 'bitwise-not'
	BitwiseOr			= 'bitwise-or'
	BitwiseRightShift	= 'bitwise-right-shift'
	BitwiseXor			= 'bitwise-xor'
	DecrementPostfix	= 'postfix-decrement'
	DecrementPrefix		= 'prefix-decrement'
	Division
	Imply
	IncrementPostfix	= 'postfix-increment'
	IncrementPrefix		= 'prefix-increment'
	Modulo
	Multiplication
	Negative
	Or
	Quotient
	Subtraction
	Xor
}

const $operatorTypes = {
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
	[Operator::Imply]: ['Boolean']
	[Operator::IncrementPostfix]: ['Number']
	[Operator::IncrementPrefix]: ['Number']
	[Operator::Modulo]: ['Number']
	[Operator::Multiplication]: ['Number']
	[Operator::Negative]: ['Number']
	[Operator::Or]: ['Boolean']
	[Operator::Quotient]: ['Number']
	[Operator::Subtraction]: ['Number']
	[Operator::Xor]: ['Boolean']
}

include {
	'../operator/assignment'
	'../operator/binary'
	'../operator/polyadic'
	'../operator/unary'
}