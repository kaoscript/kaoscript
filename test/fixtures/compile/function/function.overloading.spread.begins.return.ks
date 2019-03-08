func foobar(value: Array, ...args) {
	return 'Array'
}
func foobar(value: String, ...args) {
	return 'String'
}
func foobar(value, ...args) {
	return 'Any'
}

export foobar