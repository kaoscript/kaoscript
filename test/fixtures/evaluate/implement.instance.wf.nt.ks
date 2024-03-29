require expect: func

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

expect(shape.draw()).to.equals(`I'm drawing with a yellow pencil.`)
expect(shape.draw('rectangle')).to.equals(`I'm drawing a yellow rectangle.`)
expect(shape.draw('red', 'rectangle')).to.equals(`I'm drawing a red rectangle.`)