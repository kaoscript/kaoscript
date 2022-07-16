func foobar(...args) {
	return 0
}
func foobar(x: Number, ...args, y: Number) {
	return 1
}
func foobar(x: Number, ...args, y: String) {
	return 2
}
func foobar(x: String, ...args, y: Number) {
	return 3
}
func foobar(x: String, ...args, y: String) {
	return 4
}