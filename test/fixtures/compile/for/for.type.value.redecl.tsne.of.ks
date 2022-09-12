extern console

func foobar(values) {
	var mut value: String?

	for value: String of values {
		console.log(`\(value)`)
	}
}