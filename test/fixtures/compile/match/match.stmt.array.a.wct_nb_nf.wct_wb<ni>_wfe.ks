func foobar(value?) {
	match value {
		Number {
		}
		Array with [argument: Number] when argument > 0 {
		}
	}
}