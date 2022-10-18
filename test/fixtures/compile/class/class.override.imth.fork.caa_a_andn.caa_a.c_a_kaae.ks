abstract class ClassA {
	abstract foobar(x, y? = null)
}

abstract class ClassB extends ClassA {
	abstract foobar(x)
}

class ClassC extends ClassB {
	foobar(x) => 1
	override foobar(x, y) => 2
}
