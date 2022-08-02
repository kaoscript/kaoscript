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

var dyn r = new Rectangle('black')

console.log(r.draw())