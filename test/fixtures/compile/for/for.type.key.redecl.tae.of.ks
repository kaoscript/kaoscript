extern console

func foobar(values) {
	let key

	for _, key of values {
		console.log(`\(key)`)
	}
}