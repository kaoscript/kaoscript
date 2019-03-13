#![target(safari-v8)]

class Shape {
	private {
		_color: string = ''
	}

	constructor(@color)
}

#[if(any(trident, safari-v8))]
impl Shape {
	draw_trident(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}