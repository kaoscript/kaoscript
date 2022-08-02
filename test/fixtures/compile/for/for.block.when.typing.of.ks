extern console

func foobar(values: Dictionary) {
	for var value of values when value is String {
		console.log(`\(value)`)
	}
}