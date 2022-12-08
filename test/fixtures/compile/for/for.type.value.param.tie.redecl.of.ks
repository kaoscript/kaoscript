extern console

func foobar(values: Object<Number>) {
	var mut value: String = ''

	for value of values {
		console.log(`\(value)`)
	}
}