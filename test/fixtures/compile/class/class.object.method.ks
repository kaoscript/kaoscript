class Foobar {
	private {
		_x
		_y
	}
	xy() => ({
		xy: this.xy(@x, @y)
	})
	xy(x, y) => x + y
}