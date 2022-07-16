class ClassA {
	foobar(value: ClassA?): Boolean => true
}

class ClassB extends ClassA {
	foobar(value: ClassA) => true
}

class ClassC extends ClassB {
	foobar(value: ClassC) => true
}