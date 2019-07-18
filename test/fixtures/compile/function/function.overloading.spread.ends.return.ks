func foobar(...args, value: Array) {
	return 'Array'
}
func foobar(...args, value: String) {
	return 'String'
}
func foobar(...args, value) {
	return 'Any'
}

export foobar