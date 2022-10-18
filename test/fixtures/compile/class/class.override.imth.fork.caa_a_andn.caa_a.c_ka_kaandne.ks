abstract class ClassA {
	abstract foobar(x, y? = null)
}

abstract class ClassB extends ClassA {
	abstract foobar(x)
}

class ClassC extends ClassB {
	override foobar(x) => 1
	override foobar(x, y? = null) => 2
}
