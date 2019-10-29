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

const s = new Shape('x', 'y')

export Shape