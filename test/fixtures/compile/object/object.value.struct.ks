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
		start: Position.new(
			x: @x
			y: @y
		)
	})
	position_dict() => ({
		x: @x
		y: @y
	})
	position_struct() => Position.new(
		x: @x
		y: @y
	)
}