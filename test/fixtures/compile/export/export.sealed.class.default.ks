extern console: {
	log(...args)
}

sealed class Shape {
	private {
		_color: string = ''
	}

	constructor(@color)
}

impl Shape {
	draw(shape): string {
		return `I'm drawing a \(this._color) \(shape).`
	}
}

export console, Shape