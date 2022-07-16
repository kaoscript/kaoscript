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

let r = new Rectangle('black')

console.log(r.draw())

export Shape, Rectangle