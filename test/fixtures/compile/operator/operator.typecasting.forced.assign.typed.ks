extern console

func foobar() {
	let values: Array<String>

	values = quxbaz()!!

	for const value in values {
		console.log(`\(value)`)
	}
}

func quxbaz(): String => 'foobar'