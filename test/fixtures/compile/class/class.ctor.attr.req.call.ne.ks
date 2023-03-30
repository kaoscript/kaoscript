class Foobar {
	private {
		@x: Number?
	}
	constructor(@x!?)
}

var f = new Foobar(null)