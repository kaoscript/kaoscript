extern sealed class ClassA

class ClassB extends ClassA {
	private {
		_z: Number	= 0
	}
	constructor(x: Number, y: Number) {
		super(x, y)
		
		@z = x * y
	}
}

class ClassC extends ClassB {
	private {
		_w: Number	= 0
	}
	constructor(x: Number, y: Number) {
		super(x, y)
		
		@w = @z * @z
	}
}

export ClassA, ClassB, ClassC