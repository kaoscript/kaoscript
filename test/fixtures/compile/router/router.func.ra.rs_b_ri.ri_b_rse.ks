func foobar(...strings: Array<String>, flag: Boolean, ...numbers: Array<Number>) {
	return 0
}
func foobar(...numbers: Array<Number>, flag: Boolean, ...strings: Array<String>) {
	return 1
}
func foobar(...args) {
	return 2
}