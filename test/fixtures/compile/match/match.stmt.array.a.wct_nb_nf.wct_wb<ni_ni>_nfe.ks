func foobar(value?) {
	match value {
		Number {
		}
		Array with [x: Number, y: Number] {
		}
	}
}