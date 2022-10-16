class Foobar {
	private {
		@x: Any
		@y: Any?
	}
	constructor(@x, @y = @x.foobar())
}