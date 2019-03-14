#![target(jsc-v12)]

class Shape {
	private {
		_color: string = ''
	}

	constructor(@color)
}

#[if(any(trident, lt(jsc-v10)))]
impl Shape {
	draw_trident(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}