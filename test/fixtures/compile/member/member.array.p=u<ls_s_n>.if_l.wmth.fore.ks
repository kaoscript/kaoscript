func foobar(values: String[] | String | Null) {
	if values is Array {
		values.push('foo', 'bar')

		for var value in values {
			echo(`\(value)`)
		}
	}
}