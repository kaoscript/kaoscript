extern console

func foobar(values) {
	var dyn value: Number = 0

	for value: String in values {
		console.log(`\(value)`)
	}
}