struct Position {
	x: Number
	y: Number
}

class Foobar {
	private {
		@x: Number	= 0
		@y: Number	= 0
	}
	position() => ({
		start: new Position(
			x: @x
			y: @y
		)
	})
	position_dict() => ({
		x: @x
		y: @y
	})
	position_struct() => new Position(
		x: @x
		y: @y
	)
}