extern console

func foobar(values) {
	for var items, index in values split 1 {
		console.log(index, items)
	}
}