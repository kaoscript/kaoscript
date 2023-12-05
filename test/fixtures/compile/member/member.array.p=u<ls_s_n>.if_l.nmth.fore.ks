func foobar(values: String[] | String | Null) {
	if values is Array {
		for var value in values {
			echo(`\(value)`)
		}
	}
}