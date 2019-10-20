extern console

func foobar(values) {
	let key: String

	for _, key of values {
		console.log(`\(key)`)
	}
}