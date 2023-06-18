type TypeA = {
	foobar(): String
}

class ClassA implements TypeA {
	private override foobar() {
		return ''
	}
}