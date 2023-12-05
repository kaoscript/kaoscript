func foobar(add) {
	var values = []

	if add {
		echo(`\(values[0])`)
	}
	else {
		values.push('foo', 'bar')

		echo(`\(values[0])`)
	}
}