tuple Position(Number, Number)

class Foobar {
	private {
		@x: Number	= 0
		@y: Number	= 0
	}
	position() => ({
		start: Position.new(@x, @y)
	})
	position_dict() => ({
		x: @x
		y: @y
	})
	position_tuple() => Position.new(@x, @y)
}