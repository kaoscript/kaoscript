extern console

class ErrorA extends Error {
}

class ErrorB extends ErrorA {
}

class Shape {
	private {
		_color: String
	}

	constructor(@color)

	draw(): String ~ ErrorA {
		return @color
	}
}

class Rectangle extends Shape {
	constructor(@color) {
		super(color)
	}

	override draw() ~ ErrorB {
		return `I'm drawing a \(@color) rectangle.`
	}
}

var dyn r = Rectangle.new('black')

try {
	console.log(r.draw())
}

export Shape, Rectangle