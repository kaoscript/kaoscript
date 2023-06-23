type TypeA = [String]
type TypeB = [Any, Number]
type TypeC = TypeA & TypeB

tuple TupleA implements TypeC [
	foobar: String
	quxbaz: Number
]