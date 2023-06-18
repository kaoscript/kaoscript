extern console: {
	log(...args)
}

class Shape {
	private {
		_color: string = ''
	}

	static makeBlue(): Shape {
		return Shape.new('blue')
	}

	constructor(@color)

	draw(): string {
		return `I'm drawing a \(@color) rectangle.`
	}
}

export Shape