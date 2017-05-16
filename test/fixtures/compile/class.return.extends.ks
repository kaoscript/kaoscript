abstract class ClassA {
	abstract foo(): String
}

class ClassB extends ClassA {
	foo() => 42
}