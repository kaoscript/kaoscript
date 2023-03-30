extern console

type Foobar = {
	line: Number
	element: String
}

func foobar(values: Foobar{}) {
	for var {line, element} of values {
		console.log(`\(element)`)
	}
}