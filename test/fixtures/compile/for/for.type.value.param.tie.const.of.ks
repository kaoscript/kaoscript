extern console

func foobar(values: Object<Number>) {
	for var value: String of values {
		console.log(`\(value)`)
	}
}