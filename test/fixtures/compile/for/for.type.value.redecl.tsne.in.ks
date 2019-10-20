extern console

func foobar(values) {
	let value: String?

	for value: String in values {
		console.log(`\(value)`)
	}
}