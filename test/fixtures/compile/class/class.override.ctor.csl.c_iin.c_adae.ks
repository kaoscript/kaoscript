extern sealed class Foobar

class Quxbaz extends Foobar {
	private {
		@x: Number
		@y: Number?
	}
	constructor(@x, @y)
}

class Corge extends Quxbaz {
	constructor(x = 0, y) {
		super(x, y)
	}
}