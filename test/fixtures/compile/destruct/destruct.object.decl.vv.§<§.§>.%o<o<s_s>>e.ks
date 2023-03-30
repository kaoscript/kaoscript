extern console

func foobar(values: { bar: { n1: String, n2: String } }) {
	var {bar % { n1, n2 }} = values

	console.log(`\(n1), \(n2)`)
}