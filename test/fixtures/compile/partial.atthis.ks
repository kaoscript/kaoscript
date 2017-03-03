class Shape {
	private {
		_color: string = ''
	}
	
	constructor(@color)
}

impl Shape {
	draw(canvas): string {
		return `I'm drawing a \(@color) rectangle.`
	}
}