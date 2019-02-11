class Shape {
	private {
		_color: String = ''
	}

	constructor(@color)

	color() ~ Error => @color
	color(@color) ~ Error => this
}

impl Shape {
	draw(canvas): String ~ Error {
		return `I'm drawing a \(this.color()) rectangle.`
	}
}

export Shape