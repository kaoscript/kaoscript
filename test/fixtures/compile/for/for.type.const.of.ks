extern console

func foobar(values) {
	for const value: String of values {
		console.log(`\(value)`)
	}
}