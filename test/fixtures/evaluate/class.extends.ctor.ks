require expect: func

class Shape {
	private {
		@color: String
	}

	constructor(@color) {
		expect(color).to.equal('black')
		expect(@color).to.equal('black')
	}
}

class Rectangle extends Shape {
	constructor(color) {
		super(color)
	}
}

const r = new Rectangle('black')