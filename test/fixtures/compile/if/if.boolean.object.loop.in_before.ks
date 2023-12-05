func foobar(values) {
	var mut context = { flag: false }

	for var value in values {
		if value.flag {
			context = { flag: true }
		}

		if context.flag {
			echo(value)
		}
	}
}