extern console

func foobar(values) {
	var dyn key: String

	for _, key of values {
		console.log(`\(key)`)
	}
}