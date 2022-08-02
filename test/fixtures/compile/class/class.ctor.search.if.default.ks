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
		if color == 'blue' {
			super('smurf')
		}
		else {
			super(color)
		}
	}

	draw() {
		return `I'm drawing a \(@color) rectangle.`
	}
}

var dyn r = new Rectangle('black')

console.log(r.draw())