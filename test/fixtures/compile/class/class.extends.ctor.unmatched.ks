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

const s = new Shape('red')
const r = new Rectangle('red')