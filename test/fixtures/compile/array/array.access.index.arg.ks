func foobar() {
	var values = []

	quxbaz(values)

	echo(values[0])
}

func quxbaz(values) {
	values.push(1, 2, 3)
}