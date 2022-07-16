extern console

class Shape {
	private {
		_color: String
	}

	constructor(@color)

	draw(): String => ''
}

class Rectangle extends Shape {
	constructor(@color) {
		super(color)
	}

	draw(): Number {
		return 42
	}
}

let r = new Rectangle('black')

console.log(r.draw())