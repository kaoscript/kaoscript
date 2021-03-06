extern console: {
	log(...args)
}

sealed class Shape {
	private {
		_color: string = ''
	}
	
	static makeBlue(): Shape {
		return new Shape('blue')
	}
	
	constructor(@color)
	
	draw(): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}

impl Shape {
	makeRed(): Shape {
		this._color = 'red'
		
		return this
	}
	
	static makeRed(): Shape {
		return new Shape('red')
	}
}

console.log(new Shape('blue').draw())

console.log(new Shape('blue').makeRed().draw())