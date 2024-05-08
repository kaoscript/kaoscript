extern console

func foobar(values, begin) {
	for var value in values from if begin set 0 else 1 {
		console.log(value)
	}
}