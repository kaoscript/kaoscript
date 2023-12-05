func foobar(values: String[]?) {
	if ?values {
		for var value in values {
			echo(`\(value)`)
		}
	}
}