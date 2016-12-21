class Shape {
	private {
		_color: string = ''
	}
	
	$create(@color: string)
}

impl Shape {
	draw(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}