class Foobar {
	private {
		@values: Array<Number>	= []
	}
	clone(): Foobar {
		const clone = new Foobar()

		clone._values = [...@values]

		return clone
	}
}