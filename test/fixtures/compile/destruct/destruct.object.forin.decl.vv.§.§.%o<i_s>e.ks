extern console

func foobar(values: {line: Number, element: String}[]) {
	for var {line, element} in values {
		console.log(`\(element)`)
	}
}