require expect: func

class Shape {
	private {
		_color: string = ''
	}
	
	static makeBlue(): Shape {
		return new Shape('blue')
	}
	
	constructor(@color: string)
	
	draw(): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}

impl Shape {
	static makeRed(): Shape {
		return new Shape('red')
	}
}

let shape = Shape.makeRed()
expect(shape.draw()).to.equals(`I'm drawing a red rectangle.`)