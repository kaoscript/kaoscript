#![target(jsc-v8)]

class Shape {
	private {
		_color: string = ''
	}

	constructor(@color)
}

#[if(any(trident, gte(jsc-v10)))]
impl Shape {
	draw_trident(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}