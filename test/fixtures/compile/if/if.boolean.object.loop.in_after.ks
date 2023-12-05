func foobar(values) {
	var mut context = { flag: false }

	for var value in values {
		if context.flag {
			echo(value)
		}

		if value.flag {
			context = { flag: true }
		}
	}
}