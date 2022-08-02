extern console

func foobar(values) {
	var dyn key

	for _, key of values {
		console.log(`\(key)`)
	}
}