extern console

func foobar(values) {
	var dyn key

	for _, key in values {
		console.log(`\(key)`)
	}
}