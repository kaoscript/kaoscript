class Shape {
	private {
		_color: string = ''
	}
	
	constructor(@color: string)
}

#[if(ecma-v6)]
impl Shape {
	draw_es6(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}

#[if(ecma-v5)]
impl Shape {
	draw_es5(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}

#[if(any(trident, safari-v8))]
impl Shape {
	draw_trident(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}