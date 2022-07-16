class ClassA {
	foobar(x: ClassA) => false
}

class ClassB extends ClassA {
	foobar(x: ClassB) => false
	foobar(x: ClassC | ClassD) => false
}

class ClassC extends ClassA {
}

class ClassD extends ClassA {
}