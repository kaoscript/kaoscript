extern console

func foobar(values, size) {
	for var [x, y], index in values split size {
		console.log(index, x, y)
	}
}