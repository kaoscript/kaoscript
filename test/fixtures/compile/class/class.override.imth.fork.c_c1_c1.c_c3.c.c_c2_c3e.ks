class ClassA {
	foobar(x: ClassA) {
	}
	quxbaz(x: ClassA) {
	}
}

class ClassB extends ClassA {
	quxbaz(x: ClassC) {
	}
}

class ClassC extends ClassA {
}

class ClassD extends ClassA {
	foobar(x: ClassB) {
	}
	foobar(x: ClassC) {
	}
}