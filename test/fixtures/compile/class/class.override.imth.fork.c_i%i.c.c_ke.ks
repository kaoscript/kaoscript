class ClassA {
	foobar(x: Number): Number => x
}

class ClassB extends ClassA {
}

class ClassC extends ClassB {
	override foobar(x) => x
}