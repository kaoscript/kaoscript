func foobar(values: String{}?) {
	if ?values {
		for var value of values {
			echo(`\(value)`)
		}
	}
}