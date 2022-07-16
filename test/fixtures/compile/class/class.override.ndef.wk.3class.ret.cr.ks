class ClassA {
}

class ClassB extends ClassA {
}

class ClassC extends ClassB {
}

class Foobar {
	foobar(): ClassB => new ClassB()
}

class Quxbaz extends Foobar {
	override foobar(): ClassA => new ClassA()
}