extern console

func foobar() {
	var dyn values: Array<String>

	values = quxbaz()!!

	for var value in values {
		console.log(`\(value)`)
	}
}

func quxbaz(): String => 'foobar'