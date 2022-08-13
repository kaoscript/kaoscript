class Foobar {
	private {
		@x: Number
	}
	constructor(x: Number) {
		this.x(x)
	}
	x(x: Number) {
		@x = x

		var y = @x / 2
	}
}

export Foobar