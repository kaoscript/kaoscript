extern console

func foobar() {
	const values: Array<String> = quxbaz()!!

	for const value in values {
		console.log(`\(value)`)
	}
}

func quxbaz(): String => 'foobar'