#![target(ecma-v5)]
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
		start: Position(
			x: @x
			y: @y
		)
	})
	position_dict() => ({
		x: @x
		y: @y
	})
	position_struct() => Position(
		x: @x
		y: @y
	)
}