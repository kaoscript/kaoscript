#![format(classes='es5', functions='es5')]

extern console

class Shape {
	private {
		_color: string
	}

	constructor(@color)

	draw(): string {
		return @color
	}
}

class Rectangle extends Shape {
	constructor(color) {
		super(color)
	}

	draw() {
		return 'I\'m drawing a ' + this._color + ' rectangle.'
	}
}

let r = new Rectangle('black')

console.log(r.draw())