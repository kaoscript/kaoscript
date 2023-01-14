extern console

func foobar(values) {
	for var [x], index in values split 1 {
		console.log(index, x)
	}
}