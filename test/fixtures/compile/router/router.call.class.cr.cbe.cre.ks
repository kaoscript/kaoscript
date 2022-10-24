class ClassA {
}

class ClassB extends ClassA {
}

class ClassX {
	foobar(x: ClassB) => 1
	foobar(x: ClassA) => 2
}

func foobar(a: ClassA) {
	var c = new ClassX()

	c.foobar(a)
}

foobar(new ClassB())