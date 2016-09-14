extern console: {
	log(...args)
}

final class Shape {
	private {
		_color: string = ''
	}
	
	Shape(@color: string)
}

impl Shape {
	draw(shape) -> string {
		return `I'm drawing a \(this._color) \(shape).`
	}
}

export console, Shape