extern console

class Shape {
	private {
		_color: String
	}

	constructor(@color)
}

class Rectangle extends Shape {
	constructor(@color) {
		super(color)
	}

	override draw() {
		return `I'm drawing a \(@color) rectangle.`
	}
}

var dyn r = new Rectangle('black')

console.log(r.draw())