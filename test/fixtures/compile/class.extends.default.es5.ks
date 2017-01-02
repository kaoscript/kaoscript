#![cfg(format(classes='es5', functions='es5'))]

extern console, Error

class Shape {
	private {
		_color: string
	}
	
	$create(@color)
	
	draw(): string {
		throw new Error('Not Implemented')
	}
}

class Rectangle extends Shape {
	$create(color) {
		super(color)
	}
	
	draw() {
		return 'I\'m drawing a ' + this._color + ' rectangle.'
	}
}

let r = new Rectangle('black')

console.log(r.draw())