abstract class ClassA {
	abstract foobar()
}

abstract class ClassB extends ClassA {
}

class ClassC extends ClassB {
	private {
		@parent: ClassB
	}

	constructor(@parent)

	proxy @parent {
		foobar
	}
}