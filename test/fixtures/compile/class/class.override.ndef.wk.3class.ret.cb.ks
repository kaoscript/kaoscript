class ClassA {
}

class ClassB extends ClassA {
}

class ClassC extends ClassB {
}

class Foobar {
	foobar(): ClassB => ClassB.new()
}

class Quxbaz extends Foobar {
	override foobar(): ClassC => ClassC.new()
}