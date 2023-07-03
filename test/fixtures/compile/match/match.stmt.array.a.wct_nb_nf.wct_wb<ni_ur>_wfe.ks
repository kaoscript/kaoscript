func foobar(value?) {
	match value {
		Number {
		}
		Array with var [argument: Number, ...] when argument > 0 {
		}
	}
}