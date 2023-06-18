type TypeA = {
	foobar(): String
}

class ClassA implements TypeA {
	override foobar() {
		return 0
	}
}