extern console

class Shape {
	private {
		_color: String
	}

	constructor(@color)

	draw() {
	}
}

class Rectangle extends Shape {
	constructor(@color) {
		super(color)
	}

	draw(): String {
		return `I'm drawing a \(@color) rectangle.`
	}
}

var dyn r = Rectangle.new('black')

console.log(r.draw())