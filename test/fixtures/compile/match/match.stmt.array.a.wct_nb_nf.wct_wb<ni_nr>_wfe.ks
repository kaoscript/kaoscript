func foobar(value?) {
	match value {
		Number {
		}
		Array with var [argument: Number, ...arguments] when argument > 0 {
		}
	}
}