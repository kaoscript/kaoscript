abstract class ClassA {
	abstract foobar(x, y? = null)
}

abstract class ClassB extends ClassA {
	foobar(x) => 1
}

class ClassC extends ClassB {
	foobar(x) => super(x)
	foobar(x, y? = null) => 2
}
