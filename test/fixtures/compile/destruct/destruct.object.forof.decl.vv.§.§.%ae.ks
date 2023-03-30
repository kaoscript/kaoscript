extern console

func foobar(values) {
	for var {line, element} of values {
		console.log(`\(element)`)
	}
}