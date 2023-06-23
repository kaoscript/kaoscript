type TypeA = {
	foobar: String
}
type TypeB = {
	quxbaz: Number
}
type TypeC = TypeA & TypeB

struct StructA implements TypeC {
	foobar: String
	quxbaz: Number
}