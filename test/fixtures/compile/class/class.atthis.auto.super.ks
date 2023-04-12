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
	private {
		_backgroundColor: String
	}

	constructor(@color, @backgroundColor) {
		super(color)
	}

	draw() {
		return 'I\'m drawing a ' + @color + ' rectangle.'
	}
}

var dyn r = Rectangle.new('black', 'white')

console.log(r.draw())