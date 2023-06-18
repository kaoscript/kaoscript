type TypeA = {
	foobar(): String
}

class ClassA implements TypeA {
	foobar(): String {
		return ''
	}
}