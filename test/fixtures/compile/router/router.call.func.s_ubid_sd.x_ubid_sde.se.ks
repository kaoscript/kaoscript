func foobar(a: String, b: Boolean | Number = 0, c: String = '') {
	return 0
}
func foobar(a: RegExp, b: Boolean | Number = 0, c: String = '') {
	return 1
}

foobar('hello')