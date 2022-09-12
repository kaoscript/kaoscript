extern console

func foobar(values) {
	var mut value: String?

	for value: String in values {
		console.log(`\(value)`)
	}
}