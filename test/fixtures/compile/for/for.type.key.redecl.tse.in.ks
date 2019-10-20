extern console

func foobar(values) {
	let key: String

	for _, key in values {
		console.log(`\(key)`)
	}
}