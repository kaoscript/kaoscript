extern console

class Shape {
	private {
		_color: String
	}

	constructor(@color)

	draw(): String {
		return @color
	}
}

class Rectangle extends Shape {
	constructor(@color) {
		super(color)
	}

	draw() {
		return `I'm drawing a \(@color) rectangle.`
	}
}

var dyn r = Rectangle.new('black')

console.log(r.draw())