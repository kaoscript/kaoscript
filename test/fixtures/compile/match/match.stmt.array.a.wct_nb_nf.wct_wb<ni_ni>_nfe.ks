func foobar(value?) {
	match value {
		Number {
		}
		Array with var [x: Number, y: Number] {
		}
	}
}