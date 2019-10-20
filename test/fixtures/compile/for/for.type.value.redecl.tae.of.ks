extern console

func foobar(values) {
	let value

	for value: String of values {
		console.log(`\(value)`)
	}

	console.log(`\(value)`)
}