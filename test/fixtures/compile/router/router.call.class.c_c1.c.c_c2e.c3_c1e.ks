class ClassA {
	foobar(value: ClassA): Boolean => false
}

class ClassB extends ClassA {
}

class ClassC extends ClassA {
	foobar(value: ClassB): Boolean => false
}

func foobar(x: ClassC, y: ClassA) {
	if x.foobar(y) {
	}
}