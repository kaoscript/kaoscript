extern console

func foobar(values) {
	var dyn key: Number

	for _, key in values {
		console.log(`\(key)`)
	}
}