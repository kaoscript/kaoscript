func test(x) => true

func foobar(i: Number, b: Boolean) {
	var mut x: Number

	unless b {
		x = 42
	}

	if test(x <- null) {

	}
}