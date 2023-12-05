func foobar(values: String{}?) {
	if ?values {
		values['foo'] = 'foo'

		for var value of values {
			echo(`\(value)`)
		}
	}
}