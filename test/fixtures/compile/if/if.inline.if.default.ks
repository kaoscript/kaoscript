func foobar(test) {
	var value = if test(0) {
		if test(1) {
			set 42
		}
		else {
			set 1
		}
	}
	else {
		set 0
	}
}