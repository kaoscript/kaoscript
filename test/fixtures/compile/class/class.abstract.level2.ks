abstract class Foo {
	abstract greet(name): String
}

class Bar extends Foo {
	greet(name): String => `Hello \(name)!`
}

class Qux extends Bar {
}