require expect: func

final class Shape {
	private {
		_color: string = ''
	}
	
	Shape(@color: string)
	
	draw() -> string {
		return `I'm drawing with a \(this._color) pencil.`
	}
	
	draw(shape) -> string {
		return `I'm drawing a \(this._color) \(shape).`
	}
}

let form = 'rectangle'

impl Shape {
	drawing() as draw with form
}

let shape: Shape = new Shape('yellow')

expect(shape.draw()).to.equals(`I'm drawing with a yellow pencil.`)
expect(shape.draw('rectangle')).to.equals(`I'm drawing a yellow rectangle.`)
expect(shape.drawing()).to.equals(`I'm drawing a yellow rectangle.`)