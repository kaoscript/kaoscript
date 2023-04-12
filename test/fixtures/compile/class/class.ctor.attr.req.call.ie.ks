class Foobar {
	private {
		@x: Number?
	}
	constructor(@x!?)
}

var f = Foobar.new(0)