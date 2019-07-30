extern console: {
	log(...args)
}

class Shape {
	private {
		_color: string = ''
	}

	static makeBlue(): Shape {
		return new Shape('blue')
	}

	constructor(@color)

	draw(): string {
		return `I'm drawing a \(@color) rectangle.`
	}
}

impl Shape {
	private _name: string
}

let shape = Shape.makeBlue()

console.log(shape.draw())