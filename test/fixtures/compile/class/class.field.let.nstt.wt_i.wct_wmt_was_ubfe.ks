class Foobar {
	private {
		@x: Number
	}
	constructor(x: Number) {
		this.x(x)
	}
	x(x: Number) {
		var y = @x / 2

		@x = x
	}
}