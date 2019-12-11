extern console

func foobar(values: Array) {
	for const value in values when value is String {
		console.log(`\(value)`)
	}
}