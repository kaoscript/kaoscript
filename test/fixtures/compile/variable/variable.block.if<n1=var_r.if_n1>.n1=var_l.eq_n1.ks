func foobar(test) {
	if test() {
		var value = test()

		if value {
		}
	}

	var late value

	value = test()
}