extern console

func foobar(values) {
	var mut key: Number

	for _, key in values {
		console.log(`\(key)`)
	}
}