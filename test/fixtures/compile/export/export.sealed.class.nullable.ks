extern console: {
	log(...args)
}

sealed class Shape {
	private {
		_shape: String
	}

	constructor(@shape)
}

impl Shape {
	draw(color?): String {
		if ?color {
			return `I'm drawing a \(color) \(@shape).`
		}
		else {
			return `I'm drawing a \(@shape).`
		}
	}
}

export console, Shape