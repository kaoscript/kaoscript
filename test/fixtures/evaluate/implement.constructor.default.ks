require expect: func

class Shape {
	private {
		_color: string = ''
	}
	constructor(@color)
	color() => @color
	draw(): String => `I'm drawing a \(@color) rectangle.`
}

impl Shape {
	constructor() {
		@color = 'red'
	}
}

var dyn shape = Shape.new()
expect(shape.draw()).to.equals(`I'm drawing a red rectangle.`)