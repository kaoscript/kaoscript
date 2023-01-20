class Foobar {
	private {
		@values: Number?[] = []
	}
	foobar(fn) {
		return [fn(value, index, this) for var value, index in @values when ?value]
	}
}