class Foobar {
	private {
		@values: Number[] = []
	}
	foobar(fn) {
		return [value for var value, index in @values when fn(value, index, this)]
	}
}