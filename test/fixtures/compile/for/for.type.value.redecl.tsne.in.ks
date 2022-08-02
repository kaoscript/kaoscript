extern console

func foobar(values) {
	var dyn value: String?

	for value: String in values {
		console.log(`\(value)`)
	}
}