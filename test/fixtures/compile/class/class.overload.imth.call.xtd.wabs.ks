abstract class ClassA {
	abstract foobar(x: String = 'void')
}

abstract class ClassB extends ClassA {
	foobar(x: String, y: Number) => @foobar(x)
}