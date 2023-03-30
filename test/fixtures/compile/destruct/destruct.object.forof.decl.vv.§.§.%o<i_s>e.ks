extern console

func foobar(values: {line: Number, element: String}{}) {
	for var {line, element} of values {
		console.log(`\(element)`)
	}
}