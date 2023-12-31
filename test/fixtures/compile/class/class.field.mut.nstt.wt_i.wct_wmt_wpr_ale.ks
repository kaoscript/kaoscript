class Foobar {
	private {
		@x: Number
	}
	constructor(x: Number) {
		this.x(x)
	}
	x(@x) => this
}

export Foobar