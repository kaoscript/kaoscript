func foobar(add) {
	var values = []

	if add {
		values.push('foo', 'bar')

		echo(`\(values[0])`)
	}
	else {
		values.push('qux')

		echo(`\(values[0])`)
	}

	echo(`\(values[0])`)
}