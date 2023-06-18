type TypeA = {
	foobar(): String
}
type TypeB = {
	quxbaz(): Number
}

class ClassA implements TypeA, TypeB {
	override foobar() {
		return ''
	}
	override quxbaz() {
		return 0
	}
}