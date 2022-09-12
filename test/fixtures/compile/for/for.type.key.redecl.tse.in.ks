extern console

func foobar(values) {
	var mut key: String = ''

	for _, key in values {
		console.log(`\(key)`)
	}
}