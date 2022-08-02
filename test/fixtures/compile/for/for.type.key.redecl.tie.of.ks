extern console

func foobar(values) {
	var dyn key: Number = 0

	for _, key of values {
		console.log(`\(key)`)
	}
}