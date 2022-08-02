class Shape {
	private {
		_color: String = ''
	}

	constructor(@color)

	color() => @color
	color(@color) => this
}

func error(message) ~ Error {
	throw new Error(message)
}

impl Shape {
	constructor(x, y) ~ Error {
		error('not supported')
	}
}

var s = new Shape('x', 'y')

export Shape