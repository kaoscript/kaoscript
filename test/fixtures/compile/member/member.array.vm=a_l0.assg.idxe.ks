func foobar() {
	var mut values = []

	values = quxbaz()

	echo(`\(values[0])`)
}

func quxbaz() => ['foo', 'bar']