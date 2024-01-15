func foobar(test) {
	var value = if test(0) {
		match test(1) {
			5 {
				set 5
			}
		}

		echo('hello')

		set 1
	}
	else {
		set 0
	}
}