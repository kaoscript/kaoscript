class ClassA {
	foobar(x: String = 'void')
}

class ClassB extends ClassA {
	foobar(x: String, y: Number) => @foobar(x)
}