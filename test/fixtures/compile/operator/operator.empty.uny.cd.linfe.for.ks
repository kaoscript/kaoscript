func foobar(values: Array<Number>?) {
	if #values {
		var mut count = 0

		for var value in values {
			count += value
		}
	}
}