type TypeA = {
	foobar(): String
}
type TypeB = {
	quxbaz(): Number
}
type TypeC = TypeA & TypeB

class ClassA implements TypeC {
	override foobar() {
		return ''
	}
	override quxbaz() {
		return 0
	}
}