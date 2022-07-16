abstract class Foo {
	abstract greet(name: String): String
}

abstract class Bar extends Foo {
	override greet(name) => name
}

class Qux extends Bar {
	override greet(name) => `Hello \(name)!`
}