extern console

func foobar(values) {
	for var items, index in values split 2 {
		console.log(index, items)
	}
}