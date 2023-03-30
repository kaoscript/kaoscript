extern console

func foobar(values: {}) {
	var {bar % { n1, n2 }} = values

	console.log(`\(n1), \(n2)`)
}