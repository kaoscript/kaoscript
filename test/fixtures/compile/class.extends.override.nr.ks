extern console

class Shape {
	private {
		_color: String
	}
	
	constructor(@color)
	
	draw(): String {
	}
}

class Rectangle extends Shape {
	constructor(@color) {
		super(color)
	}
	
	draw() {
		return `I'm drawing a \(@color) rectangle.`
	}
}

let r = new Rectangle('black')

console.log(r.draw())