func foobar(values: Number[]?) {
	if ?#values {
		var mut count = 0

		for var value in values {
			count += value
		}
	}
}