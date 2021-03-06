extern console

class Shape {
	private {
		@color: String
	}
	static makeBlue(): this => new Shape('blue')
	constructor(@color = 'black')
	draw(): String => `I'm drawing a \(@color) rectangle.`
}

impl Shape {
	private {
		lateinit @name: String
	}
	name(): @name
	name(@name): this
	toString(): String => `I'm drawing a \(@color) \(@name).`
}

const shape = Shape.makeBlue()

console.log(shape.toString())