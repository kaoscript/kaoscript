require expect: func

class Shape {
	private {
		_color: string = ''
	}

	static makeBlue(): Shape {
		return new Shape('blue')
	}

	constructor(@color)

	draw(): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}

impl Shape {
	static makeRed(): Shape {
		return new Shape('red')
	}
}

var dyn shape = Shape.makeRed()
expect(shape.draw()).to.equals(`I'm drawing a red rectangle.`)