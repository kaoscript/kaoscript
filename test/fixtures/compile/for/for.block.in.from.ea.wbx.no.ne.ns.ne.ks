extern console

func foobar(values, begin) {
	for var value in values from begin ? 0 : 1 {
		console.log(value)
	}
}