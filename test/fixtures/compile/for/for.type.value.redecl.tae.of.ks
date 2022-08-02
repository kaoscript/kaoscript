extern console

func foobar(values) {
	var dyn value

	for value: String of values {
		console.log(`\(value)`)
	}

	console.log(`\(value)`)
}