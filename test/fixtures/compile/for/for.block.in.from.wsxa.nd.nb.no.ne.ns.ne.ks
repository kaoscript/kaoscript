extern console

func foobar(values, size) {
	for var items, index in values split size() {
		console.log(index, items)
	}
}