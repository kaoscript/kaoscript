extern console

class Shape {
	private {
		_color: string
	}
	
	constructor(@color)
	
	draw(): string {
	}
}

class Rectangle extends Shape {
	constructor(@color)
	
	draw() {
		return `I'm drawing a \(@color) rectangle.`
	}
}

let r = new Rectangle('black')

console.log(r.draw())