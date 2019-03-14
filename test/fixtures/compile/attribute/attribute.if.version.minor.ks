class Shape {
	private {
		_color: string = ''
	}

	constructor(@color)
}

#[if(v8-v6.2)]
impl Shape {
	draw_es6(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}