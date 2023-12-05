func foobar(values: String[]?) {
	if ?values {
		values.push('foo', 'bar')

		for var value in values {
			echo(`\(value)`)
		}
	}
}