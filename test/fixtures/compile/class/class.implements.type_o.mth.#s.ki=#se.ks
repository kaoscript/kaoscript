type TypeA = {
	foobar(): String
}

class ClassA implements TypeA {
	private foobar(): String {
		return ''
	}
}