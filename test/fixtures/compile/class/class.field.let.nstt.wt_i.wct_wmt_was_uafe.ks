class Foobar {
	private {
		@x: Number
	}
	constructor(x: Number) {
		this.x(x)
	}
	x(x: Number) {
		@x = x

		const y = @x / 2
	}
}

export Foobar