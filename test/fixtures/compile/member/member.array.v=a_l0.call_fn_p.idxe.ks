func foobar() {
	var values = []

	quxbaz(values)

	echo(`\(values[0])`)
}

func quxbaz(values) {
	values.push('foo', 'bar')
}