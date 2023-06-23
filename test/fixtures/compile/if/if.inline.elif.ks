func foobar(test) {
	var value = if test(0) {
		pick 0
	}
	else if test(1) {
		pick 1
	}
	else {
		pick 2
	}
}