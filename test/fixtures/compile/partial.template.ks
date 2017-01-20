class Shape {
	private {
		_color: string = ''
	}
	
	constructor(@color: string)
}

let name := 'draw'

impl Shape {
	`\(name)`(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}