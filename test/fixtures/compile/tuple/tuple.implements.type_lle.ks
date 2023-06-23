type TypeA = [String]
type TypeB = [Any, Number]

tuple TupleA implements TypeA, TypeB [
	foobar: String
	quxbaz: Number
]