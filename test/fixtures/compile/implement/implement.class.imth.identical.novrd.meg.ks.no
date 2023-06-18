extern console: {
	log(...args)
}

class Shape {
	private {
		_color: string = ''
	}

	static makeBlue(): Shape {
		return Shape.new('blue')
	}

	constructor(@color)

	draw(): string {
		return `I'm drawing a \(@color) rectangle.`
	}
}

impl Shape {
	private _name: string = 'circle'

	name() => @name
	name(@name) => this

	draw(): string {
		return `I'm drawing a \(@color) \(@name).`
	}
}

var dyn shape = Shape.makeBlue()

console.log(shape.draw())