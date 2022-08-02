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

var s = new Shape('red')
var r = new Rectangle('red')