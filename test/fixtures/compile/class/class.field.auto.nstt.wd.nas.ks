class Foobar {
	private {
		auto @x	= 42
	}
	x(): @x
	y(): Number => @x
}

export Foobar