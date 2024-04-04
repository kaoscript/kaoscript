extern console

func foobar() {
	var values: Array<String> = quxbaz()!!

	for var value in values {
		console.log(`\(value)`)
	}
}

func quxbaz(): String[] | String => ['foobar']