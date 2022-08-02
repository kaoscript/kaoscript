extern console

func foobar(values: Dictionary<Number>) {
	var dyn value: String = ''

	for value of values {
		console.log(`\(value)`)
	}
}