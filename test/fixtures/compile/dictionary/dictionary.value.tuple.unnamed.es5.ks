#![target(ecma-v5)]
tuple Position(Number, Number)

class Foobar {
	private {
		@x: Number	= 0
		@y: Number	= 0
	}
	position() => ({
		start: Position(@x, @y)
	})
	position_dict() => ({
		x: @x
		y: @y
	})
	position_tuple() => Position(@x, @y)
}