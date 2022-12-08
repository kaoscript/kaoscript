extern console

func foobar(values: Object) {
	for var value of values when value is String {
		console.log(`\(value)`)
	}
}