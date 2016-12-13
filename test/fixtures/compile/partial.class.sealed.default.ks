extern console: {
	log(...args)
}

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
console.log(shape.draw())

shape = Shape.makeRed()
console.log(shape.draw())