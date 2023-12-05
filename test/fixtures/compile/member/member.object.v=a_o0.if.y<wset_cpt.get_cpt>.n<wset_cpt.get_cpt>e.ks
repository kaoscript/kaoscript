func foobar(add) {
	var values = {}

	if add {
		values['foo'] = 'foo'

		echo(`\(values['foo'])`)
	}
	else {
		values['foo'] = 'foo'

		echo(`\(values['foo'])`)
	}

	echo(`\(values['foo'])`)
}