extern console: {
	log(...args)
}

sealed class Shape {
	private {
		_color: string = ''
	}

	constructor(@color)

	draw(): string {
		return `I'm drawing with a \(this._color) pencil.`
	}

	draw(shape): string {
		return `I'm drawing a \(this._color) \(shape).`
	}
}

impl Shape {
	draw(color, shape): string {
		return `I'm drawing a \(color) \(shape).`
	}
}


class Proxy {
	private {
		_shape: Shape
	}

	constructor(color) {
		this._shape = new Shape(color)
	}

	draw(): string => this._shape.draw()

	draw(shape): string => this._shape.draw(shape)

	draw(color, shape): string => this._shape.draw(color, shape)
}

var dyn shape = new Proxy('yellow')
console.log(shape.draw('rectangle'))
console.log(shape.draw('red', 'rectangle'))