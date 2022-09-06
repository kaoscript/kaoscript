class ClassA {
}

class ClassB extends ClassA {
}

class ClassX {
	foobar(x: ClassB) {
	}
	foobar(x: ClassA) {
	}
}

func foobar(a: ClassA) {
	var c = new ClassX()

	c.foobar(a)
}

foobar(new ClassB())