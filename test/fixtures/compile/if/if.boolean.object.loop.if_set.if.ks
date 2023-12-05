func foobar(values) {
	var context = { flag: false }

	for var value in values {
		if value.flag {
			context.flag = true
		}
	}

	if context.flag {
		echo('foobar')
	}
}