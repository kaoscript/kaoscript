impl Array {
	remove(...items?): Array {
		return this
	}
}

func foobar(data) {
	var keys = Object.keys(data)

	keys.remove('hello')
}