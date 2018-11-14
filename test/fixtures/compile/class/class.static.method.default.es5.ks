#![format(classes='es5', destructuring='es5', functions='es5')]

class Shape {
	private {
		_color: string = ''
		_type: string = ''
	}
	
	static {
		makeCircle(color: string): Shape => new Shape('circle', color)
		
		makeRectangle(color: string): Shape => new Shape('rectangle', color)
	}
	
	constructor(@type, @color)
}

let r = Shape.makeRectangle('black')