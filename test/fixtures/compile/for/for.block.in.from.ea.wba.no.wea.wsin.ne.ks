extern console

func foobar(values, begin, end) {
	for var value, index in values from begin to end step -1 {
		console.log(index, value)
	}
}