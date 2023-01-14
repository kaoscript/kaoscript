extern console

func foobar(values) {
	for var [x, y], index in values step 2 split 2 {
		console.log(index, x, y)
	}
}