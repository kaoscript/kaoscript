class Shape {
	private {
		@color: String
	}
	static makeBlue(): Shape => Shape.new('blue')
	constructor(@color = 'black')
	draw(): String => `I'm drawing a \(@color) rectangle.`
}

export Shape