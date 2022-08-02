extern console

func foobar(values: Array) {
	for var value in values when value is String {
		console.log(`\(value)`)
	}
}