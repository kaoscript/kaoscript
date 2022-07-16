class ClassA {
	foobar(x: ClassA) {
	}
}

class ClassB extends ClassA {
	foobar(x: ClassB) {
	}
}

func quxbaz(x: ClassB) {
	x.foobar(x)
}