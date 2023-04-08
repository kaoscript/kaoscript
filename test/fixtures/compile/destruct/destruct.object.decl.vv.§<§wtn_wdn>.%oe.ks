extern console

func foobar(values: {}) {
	var {bar % { n1? = null }} = values

	console.log(`\(n1)`)
}