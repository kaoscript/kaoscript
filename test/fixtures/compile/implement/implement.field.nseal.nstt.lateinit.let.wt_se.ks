extern console

class Shape {
	private {
		@color: String
	}
	static makeBlue(): Shape => Shape.new('blue')
	constructor(@color = 'black')
	draw(): String => `I'm drawing a \(@color) rectangle.`
}

impl Shape {
	private {
		late @name: String
	}
	name(): @name
	name(@name): this
	toString(): String => `I'm drawing a \(@color) \(@name).`
}

var shape = Shape.makeBlue()

console.log(shape.toString())