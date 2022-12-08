tuple Position {
	x: Number
	y: Number
}

class Foobar {
	private {
		@x: Number	= 0
		@y: Number	= 0
	}
	position() => ({
		start: Position(
			y: @y
			x: @x
		)
	})
	position_dict() => ({
		x: @x
		y: @y
	})
	position_tuple() => Position(
		y: @y
		x: @x
	)
}