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
	private {
		_backgroundColor
	}

	constructor(@color, @backgroundColor)

	draw() {
		return `I'm drawing a \(@color) rectangle.`
	}
}

var dyn r = Rectangle.new('black', 'white')

console.log(r.draw())