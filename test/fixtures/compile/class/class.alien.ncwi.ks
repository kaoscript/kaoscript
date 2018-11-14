extern sealed class ClassA

class ClassB extends ClassA {
	private {
		_x: Number	= 0
		_y: Number	= 0
	}
	x() => @x
	y() => @y
}

class ClassC extends ClassB {
	private {
		_z: Number
	}
	constructor(@x, @y, @z) {
		super()
		
		@x = x
		@y = y
	}
	z() => @z
}