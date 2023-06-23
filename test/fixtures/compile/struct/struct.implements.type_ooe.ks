type TypeA = {
	foobar: String
}
type TypeB = {
	quxbaz: Number
}

struct StructA implements TypeA, TypeB {
	foobar: String
	quxbaz: Number
}