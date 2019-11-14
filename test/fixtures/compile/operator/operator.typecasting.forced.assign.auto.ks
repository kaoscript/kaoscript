extern console

func foobar() {
	values = quxbaz()!!

	for const value in values {
		console.log(`\(value)`)
	}
}

func quxbaz(): Array<String> => ['foobar']