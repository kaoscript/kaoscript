class ClassA {
	foobar(value: ClassA?): Boolean => true
}

class ClassB extends ClassA {
	override foobar(value) => true
}

class ClassC extends ClassB {
	override foobar(value) => true
}