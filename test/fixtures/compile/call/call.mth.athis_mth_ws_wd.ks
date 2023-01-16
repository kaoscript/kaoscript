disclose Function {
	toString(): String
}

class ClassA {
	foobar() {
	}
}

class ClassB extends ClassA {
	quxbaz() {
		return @foobar.corge()
	}
}