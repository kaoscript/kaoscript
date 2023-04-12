extern console

abstract class Shape {
	private {
		_color: String
	}

	constructor(@color)

	abstract draw(): String
}

class Rectangle extends Shape {
	constructor(@color) {
		super(color)
	}

	override draw() {
		return `I'm drawing a \(@color) rectangle.`
	}
}

var dyn r = Rectangle.new('black')

console.log(r.draw())

export Shape, Rectangle