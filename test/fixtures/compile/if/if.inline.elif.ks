func foobar(test) {
	var value = if test(0) {
		set 0
	}
	else if test(1) {
		set 1
	}
	else {
		set 2
	}
}