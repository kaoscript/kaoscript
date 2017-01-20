class Shape {
	private {
		_color: string = 'black'
	}
	
	constructor(@color)
	
	destructor() {
		this._color = null
	}
	
	draw(): string {
		throw new Error('Not Implemented')
	}
}

class Rectangle extends Shape {
	private {
		_foo: string = 'bar'
	}
	
	constructor(color) {
		super(color)
	}
	
	destructor() {
		this._foo = null
	}
	
	draw() {
		return 'I\'m drawing a ' + this._color + ' rectangle.'
	}
}