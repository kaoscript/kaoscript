extern console

class Shape {
	draw(): String {
		return ''
	}
}

class Rectangle extends Shape {
	private {
		_color: String
	}

	constructor(@color)

	draw(): String {
		return `I'm drawing a \(@color) rectangle.`
	}
}

var dyn r = Rectangle.new('black')

console.log(r.draw())