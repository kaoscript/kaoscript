class Shape {
	private {
		_color: String = ''
	}

	constructor(@color)

	color() ~ Error => @color
	color(@color) ~ Error => this
}

export Shape