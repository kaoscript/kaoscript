abstract class ClassA {
	foobar(fn: (name: String): Boolean): Boolean => fn('')
}

class ClassB extends ClassA {
	override foobar(fn) => true
}
