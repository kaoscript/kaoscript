extern console

class Shape {
	private {
		_color: String
	}

	constructor(@color)

	draw(): String ~ Error {
		return @color
	}
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

try {
	console.log(r.draw())
}

export Shape, Rectangle