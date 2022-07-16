abstract class Foo {
	abstract greet(name): String
}

abstract class Bar extends Foo {
}

class Qux extends Bar {
	override greet(name) => `Hello \(name)!`
}