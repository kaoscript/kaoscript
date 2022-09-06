class ClassA {
	foobar(x: Boolean): Boolean => true
	foobar(x: String): String => ''
}

class ClassB extends ClassA {
	override foobar(x: String | Boolean): String => ''
}
