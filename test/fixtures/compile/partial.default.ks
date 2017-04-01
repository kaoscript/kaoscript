class Shape {
	private {
		_color: String = ''
	}
	
	constructor(@color)
	
	color() => @color
	color(@color) => this
}

impl Shape {
	draw(canvas): String {
		return `I'm drawing a \(this._color) rectangle.`
	}
}

export Shape