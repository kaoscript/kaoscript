require expect: func

class Shape {
	private {
		_color: string = ''
	}
	
	constructor(@color)
}

impl Shape {
	draw(): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}

let shape = new Shape('red')
expect(shape.draw()).to.equals(`I'm drawing a red rectangle.`)