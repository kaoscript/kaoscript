func foobar(x) {
	var values: Any[] = [false, false]

	for var i from 0 to~ x {
		values[i] = x ** 3
	}
}