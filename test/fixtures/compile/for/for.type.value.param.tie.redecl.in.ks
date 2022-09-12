extern console

func foobar(values: Array<Number>) {
	var mut value: String = ''

	for value in values {
		console.log(`\(value)`)
	}
}