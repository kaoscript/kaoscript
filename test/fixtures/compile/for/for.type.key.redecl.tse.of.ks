extern console

func foobar(values) {
	var mut key: String

	for _, key of values {
		console.log(`\(key)`)
	}
}