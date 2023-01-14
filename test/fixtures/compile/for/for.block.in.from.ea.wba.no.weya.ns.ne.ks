extern console

func foobar(values, begin, end) {
	for var value, index in values from begin to~ end {
		console.log(index, value)
	}
}