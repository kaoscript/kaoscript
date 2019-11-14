extern console

func foobar(values: Dictionary<Number>) {
	let value: String = ''

	for value of values {
		console.log(`\(value)`)
	}
}