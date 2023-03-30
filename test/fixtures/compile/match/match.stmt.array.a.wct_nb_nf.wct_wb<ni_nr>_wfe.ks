func foobar(value?) {
	match value {
		Number {
		}
		Array with [argument: Number, ...arguments] when argument > 0 {
		}
	}
}