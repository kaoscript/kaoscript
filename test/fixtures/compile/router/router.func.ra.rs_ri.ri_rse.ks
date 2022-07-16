func foobar(...strings: String, ...numbers: Number) {
	return 0
}
func foobar(...numbers: Number, ...strings: String) {
	return 1
}
func foobar(...args) {
	return 2
}