func foobar(test) {
	var value = if test(0) {
		for var i from 1 to 10 {
			if test(i) {
				set i
			}
		}

		echo('hello')

		set 1
	}
	else {
		set 0
	}
}