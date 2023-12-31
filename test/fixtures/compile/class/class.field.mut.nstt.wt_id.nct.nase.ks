class Foobar {
	private {
		@x: Number	= 42
	}
	x() => @x
	y(): Number => @x
}

export Foobar