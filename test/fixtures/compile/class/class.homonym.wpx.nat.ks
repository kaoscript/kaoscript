class ClassB {
	x() => 0
}

class ClassA {
	private {
		x		= null
		y: ClassB
	}

	constructor(@y)

	proxy @y {
		x
	}
}