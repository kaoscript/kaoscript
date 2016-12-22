class Shape {
	private {
		_color: string = 'black'
	}
	
	$create(@color)
	
	$destroy() {
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
	
	$create(color) {
		super(color)
	}
	
	$destroy() {
		this._foo = null
	}
	
	draw() {
		return 'I\'m drawing a ' + this._color + ' rectangle.'
	}
}