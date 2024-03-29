extern console

class Shape {
	private {
		@color: String
	}
	static makeBlue(): Shape => Shape.new('blue')
	constructor(@color = 'black')
	draw(): String => `I'm drawing a \(@color) rectangle.`
}

impl Shape {
	static NAME: String = `circle`
}

console.log(`name: \(Shape.NAME)`)