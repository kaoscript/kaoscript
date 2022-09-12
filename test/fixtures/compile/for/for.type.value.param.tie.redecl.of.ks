extern console

func foobar(values: Dictionary<Number>) {
	var mut value: String = ''

	for value of values {
		console.log(`\(value)`)
	}
}