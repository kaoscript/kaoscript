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
	
	color() => @color
	color(@color) => this
	
	draw(): string {
		return `I'm drawing a \(@color) rectangle.`
	}
}

impl Shape {
	private _name: string = 'circle'
	
	name() => @name
	name(@name) => this
	
	toString(): string {
		return `I'm drawing a \(@color) \(@name).`
	}
}

let shape = Shape.makeRed()

console.log(shape.draw())
console.log(shape.toString())