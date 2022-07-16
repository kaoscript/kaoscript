class ClassA {
	foobar(x: ClassA) {
	}
}

class ClassB extends ClassA {
	foobar(x: ClassB) {
	}
}

func quxbaz(a: ClassB) {
	a.foobar(a)
}