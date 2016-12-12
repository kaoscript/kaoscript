require expect: func

sealed class Shape {
	private {
		_color: string = ''
	}
	
	static makeBlue(): Shape {
		return new Shape('blue')
	}
	
	Shape(@color: string)
	
	draw(): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}

impl Shape {
	static makeRed(): Shape {
		return new Shape('red')
	}
}

shape = Shape.makeBlue()
expect(shape.draw()).to.equals(`I'm drawing a blue rectangle.`)

shape = Shape.makeRed()
expect(shape.draw()).to.equals(`I'm drawing a red rectangle.`)