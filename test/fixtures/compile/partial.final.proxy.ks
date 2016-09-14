extern console: {
	log(...args)
}

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

impl Shape {
	draw(color, shape) -> string {
		return `I'm drawing a \(color) \(shape).`
	}
}


class Proxy {
	private {
		_shape: Shape
	}
	
	Proxy(color) {
		this._shape = new Shape(color)
	}
	
	draw() -> string => this._shape.draw()
	
	draw(shape) -> string => this._shape.draw(shape)
	
	draw(color, shape) -> string => this._shape.draw(color, shape)
}

let shape = new Proxy('yellow')
console.log(shape.draw('rectangle'))
console.log(shape.draw('red', 'rectangle'))