func foobar(test) {
	var value = if test(0) {
		if test(1) {
			if test(2) {
				set 42
			}
		}

		echo('hello')

		set 1
	}
	else {
		set 0
	}
}