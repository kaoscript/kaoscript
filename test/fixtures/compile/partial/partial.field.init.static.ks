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
	static NAME: string = `it's a rectangle`
}

let shape = Shape.makeRed()

console.log(shape.draw())