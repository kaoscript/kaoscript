extern console: {
	log(...args)
}

class Shape {
	private {
		_color: string = ''
	}
	
	Shape(@color: string)
	
	color(): string => this._color
	
	color(@color: string): Shape => this
	
	color(shape: Shape): Shape {
		this._color = shape.color()
		
		return this
	}
}

let s = new Shape('#777')

console.log(s.color())