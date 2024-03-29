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
		@name: String
	}
	name(): valueof @name
	name(@name): valueof this
	toString(): String => `I'm drawing a \(@color) \(@name).`
}

var shape = Shape.makeBlue()

console.log(shape.toString())