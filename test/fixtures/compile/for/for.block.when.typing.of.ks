extern console

func foobar(values: Dictionary) {
	for const value of values when value is String {
		console.log(`\(value)`)
	}
}