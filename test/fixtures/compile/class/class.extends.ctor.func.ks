class Shape {
	private {
		@color: String
	}

	constructor(@color)
}

class Rectangle extends Shape {
	constructor() {
		super(color())
	}
}

func color() => 'black'