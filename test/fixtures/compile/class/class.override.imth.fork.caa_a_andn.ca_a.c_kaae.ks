abstract class ClassA {
	abstract foobar(x, y? = null)
}

abstract class ClassB extends ClassA {
	foobar(x) => 1
}

class ClassC extends ClassB {
	override foobar(x, y) => 2
}