func foobar(x) {
	var values: [] = [false for var i from 0 to~ x]

	for var i from 0 to~ x {
		values[i] = x ** 3
	}
}