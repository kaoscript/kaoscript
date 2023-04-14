tuple Position [
	x: Number
	y: Number
]

class Foobar {
	private {
		@x: Number	= 0
		@y: Number	= 0
	}
	position() => ({
		start: Position.new(
			y: @y
			x: @x
		)
	})
	position_dict() => ({
		x: @x
		y: @y
	})
	position_tuple() => Position.new(
		y: @y
		x: @x
	)
}