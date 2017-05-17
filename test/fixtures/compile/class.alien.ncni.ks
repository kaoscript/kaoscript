extern sealed class ClassA

class ClassB extends ClassA {
}

class ClassC extends ClassB {
	private {
		_x: Number
	}
	constructor(@x) {
		super()
	}
	x() => @x
}