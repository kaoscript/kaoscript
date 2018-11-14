extern sealed class ClassA

class ClassB extends ClassA {
	private {
		_x: Number	= 0
		_y: Number	= 0
	}
	constructor(@x, @y)
	x() => @x
	y() => @y
}

class ClassC extends ClassB {
}