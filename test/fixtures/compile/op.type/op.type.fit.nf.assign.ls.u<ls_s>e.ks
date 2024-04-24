extern console

func foobar() {
	var mut values: Array<String>

	values = quxbaz()!!

	for var value in values {
		console.log(`\(value)`)
	}
}

func quxbaz(): Array<String> | String => ['foobar']