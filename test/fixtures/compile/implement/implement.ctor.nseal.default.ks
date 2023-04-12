class Shape {
	private {
		_color: String = ''
	}

	constructor(@color)

	color() => @color
	color(@color) => this
}

impl Shape {
	constructor(x, y) {
		this(`\(x).\(y)`)
	}
}

var s = Shape.new('x', 'y')

export Shape