abstract class ClassA {
	abstract foobar()
}

class ClassB extends ClassA {
	override foobar()
}
class ClassC extends ClassA {
	override foobar()
}

func foobar(x: ClassB | ClassC | Null) {
	x?.foobar()
}