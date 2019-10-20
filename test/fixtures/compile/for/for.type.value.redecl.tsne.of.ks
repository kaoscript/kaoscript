extern console

func foobar(values) {
	let value: String?

	for value: String of values {
		console.log(`\(value)`)
	}
}