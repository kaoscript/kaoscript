class Foobar {
	private {
		@values: Array<Number>	= []
	}
	clone(): Foobar {
		var clone = new Foobar()

		clone._values = [...@values]

		return clone
	}
}