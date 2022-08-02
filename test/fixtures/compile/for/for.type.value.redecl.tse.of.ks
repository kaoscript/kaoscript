extern console

func foobar(values) {
	var dyn value: String

	for value: String of values {
		console.log(`\(value)`)
	}
}