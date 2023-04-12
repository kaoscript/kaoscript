extern console

class Shape {
	private {
		_color: String	 = ''
	}

	draw(): String {
		return @color
	}
}

class Rectangle extends Shape {
	constructor(@color)

	draw(): String {
		return `I'm drawing a \(@color) rectangle.`
	}
}

var dyn r = Rectangle.new('black')

console.log(r.draw())