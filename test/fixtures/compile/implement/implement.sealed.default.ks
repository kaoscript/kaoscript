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

var shape: Shape = Shape.new('yellow')
console.log(shape.draw('rectangle'))
console.log(shape.draw('red', 'rectangle'))