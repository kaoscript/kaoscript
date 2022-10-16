abstract class ClassA {
	private {
		@x: Number
	}
	constructor(@x)
}

abstract class ClassB extends ClassA {
	constructor(@x) {
		super(x)
	}
}

class ClassC extends ClassB {
	constructor(x) {
		super(x)
	}
}