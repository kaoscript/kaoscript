func foobar(values: String[] | String) {
	if values is Array {
		echo(`\(values[0])`)

		var result = [{ value: value } for var value in values]

		echo(`\(result[0].value)`)
	}
}