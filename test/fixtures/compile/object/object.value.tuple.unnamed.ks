tuple Position(Number, Number)

class Foobar {
	private {
		@x: Number	= 0
		@y: Number	= 0
	}
	position() => ({
		start: new Position(@x, @y)
	})
	position_dict() => ({
		x: @x
		y: @y
	})
	position_tuple() => new Position(@x, @y)
}