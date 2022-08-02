extern console

func foobar() {
	values = quxbaz()!!

	for var value in values {
		console.log(`\(value)`)
	}
}

func quxbaz(): Array<String> => ['foobar']