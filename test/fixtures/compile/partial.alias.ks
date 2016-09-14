class Shape {
	private {
		_color: string = ''
	}
	
	Shape(@color: string)
	
	draw(shape, canvas) -> string {
		return `I'm drawing a \(this._color) \(shape).`
	}
}

let shape = 'rectangle'

impl Shape {
	`\(shape)`(canvas) as draw with shape
}