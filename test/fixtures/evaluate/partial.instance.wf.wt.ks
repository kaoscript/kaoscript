require expect: func

final class Shape {
	private {
		_shape: string = ''
	}
	
	Shape(@shape: string)
	
	shape() => this._shape
}

final class Action {
	private {
		_color: string = ''
	}
	
	Action(@color: string)
}

impl Action {
	draw() -> string {
		return `I'm drawing with a \(this._color) pen.`
	}
	
	draw(shape: string) -> string {
		return `I'm drawing a \(this._color) \(shape).`
	}
	
	draw(shape: Shape) -> string {
		return `I'm drawing a \(this._color) \(shape.shape()).`
	}
}

let shape: Action = new Action('red')
expect(shape.draw()).to.equals(`I'm drawing with a red pen.`)
expect(shape.draw('rectangle')).to.equals(`I'm drawing a red rectangle.`)
expect(shape.draw(new Shape('circle'))).to.equals(`I'm drawing a red circle.`)