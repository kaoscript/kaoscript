extern console, Error

class Shape {
	private {
		_color: string
	}
	
	Shape(@color)
	
	draw() -> string {
		throw new Error('Not Implemented')
	}
}

class Rectangle extends Shape {
	Rectangle(color) {
		super(color)
	}
	
	draw() {
		return 'I\'m drawing a ' + this._color + ' rectangle.'
	}
}

let r = new Rectangle('black')

console.log(r.draw())