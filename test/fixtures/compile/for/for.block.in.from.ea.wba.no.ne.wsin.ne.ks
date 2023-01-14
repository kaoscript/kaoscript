extern console

func foobar(values, begin) {
	for var value, index in values from begin step -1 {
		console.log(index, value)
	}
}