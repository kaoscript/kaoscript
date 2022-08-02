extern console

func foobar(values: Array<Number>) {
	var dyn value: String = ''

	for value in values {
		console.log(`\(value)`)
	}
}