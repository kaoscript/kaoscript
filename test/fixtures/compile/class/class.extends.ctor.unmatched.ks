class Shape {
	private {
		@color: String
	}

	constructor(@color)
}

class Rectangle extends Shape {
	constructor(color) {
		super(color)
	}
}

var s = Shape.new('red')
var r = Rectangle.new('red')