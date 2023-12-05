func foobar() {
	var values = ['foobar']

	quxbaz(values)

	echo(`\(values[0])`)
}

func quxbaz(values) {
	values.push('foo', 'bar')
}