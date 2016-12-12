class Shape {
	private {
		_color: string = ''
	}
	
	Shape(@color: string)
}

let name = 'draw'

impl Shape {
	`\(name)`(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}