func foobar(test) {
	var value = if test(0) {
		if test(1) {
			pick 42
		}
	}
	else {
		pick 0
	}
}