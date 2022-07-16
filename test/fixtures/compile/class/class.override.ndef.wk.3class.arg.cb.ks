class ClassA {
}

class ClassB extends ClassA {
}

class ClassC extends ClassB {
}

class Foobar {
	foobar(x: ClassB)
}

class Quxbaz extends Foobar {
	override foobar(x: ClassC)
}