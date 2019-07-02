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
	private {
		_backgroundColor
	}

	constructor(@color, backgroundColor) {
		super(color)

		@backgroundColor = backgroundColor
	}

	draw() {
		return 'I\'m drawing a ' + @color + ' rectangle.'
	}
}

let r = new Rectangle('black', 'white')

console.log(r.draw())