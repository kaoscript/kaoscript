class ClassA {
	foobar(x: Boolean): Boolean => true
	foobar(x: String): String => ''
}

class ClassB extends ClassA {
	foobar(x: String | Boolean): String | Boolean => false
}
