extern console

func foobar(values) {
	var dyn key: String = ''

	for _, key in values {
		console.log(`\(key)`)
	}
}