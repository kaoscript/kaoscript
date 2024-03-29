extern console: {
	log(...args)
}

sealed class Shape {
	private {
		_color: string = ''
	}

	static makeBlue(): Shape {
		return Shape.new('blue')
	}

	constructor(@color)

	draw(): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}

impl Shape {
	makeRed(): Shape {
		this._color = 'red'

		return this
	}

	static makeRed(): Shape {
		return Shape.new('red')
	}
}

var mut shape: Shape = Shape.makeRed()
console.log(shape.draw())

shape = Shape.makeBlue()
console.log(shape.draw())

shape.makeRed()
console.log(shape.draw())