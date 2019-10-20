extern console

func foobar(values) {
	for let value: String of values {
		console.log(`\(value)`)
	}
}