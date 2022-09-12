extern console

func foobar(values) {
	var mut value: Number = 0

	for value: String of values {
		console.log(`\(value)`)
	}
}