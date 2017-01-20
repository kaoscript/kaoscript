class Shape {
	private {
		_color: string = ''
	}
	
	constructor(@color: string)
}

impl Shape {
	draw(canvas): string {
		return `I'm drawing a \(@color) rectangle.`
	}
}