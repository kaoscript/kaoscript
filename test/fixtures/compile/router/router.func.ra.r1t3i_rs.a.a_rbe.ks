func foobar(...args) {
	return 0
}
func foobar(...{1,3}values: Number, ...args: String) {
	return 1
}
func foobar(value) {
	return 2
}
func foobar(value, ...args: Boolean) {
	return 3
}