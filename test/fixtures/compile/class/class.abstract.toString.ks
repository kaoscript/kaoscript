abstract class ClassA {
	abstract toString(): String
}

class ClassB extends ClassA {
	toString() => 'hello'
}