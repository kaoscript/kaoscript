extern console

class Shape {
	private {
		_color: String
	}
	
	constructor(@color)
	
	draw() {
	}
}

class Rectangle extends Shape {
	constructor(@color) {
		super(color)
	}
	
	draw(): String {
		return `I'm drawing a \(@color) rectangle.`
	}
}

let r = new Rectangle('black')

console.log(r.draw())