class Shape {
	private {
		_color: String = ''
	}

	constructor(@color)

	color() => @color
	color(@color) => this
}

func error(message) ~ Error {
	throw Error.new(message)
}

impl Shape {
	constructor(x, y) ~ Error {
		error('not supported')
	}
}

var s = Shape.new('x', 'y')

export Shape