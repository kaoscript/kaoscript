extern console

class Shape {
	private {
		_color: string
	}

	constructor(@color)

	draw(): string {
		return @color
	}
}

class Rectangle extends Shape {
	constructor(@color)

	draw() {
		return `I'm drawing a \(@color) rectangle.`
	}
}

var dyn r = Rectangle.new('black')

console.log(r.draw())