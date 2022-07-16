func foobar(...args) {
	return 0
}
func foobar(...{1,3}values: Number, ...args: String) {
	return 1
}
func foobar(...value, x: Number, y: Number, z: String) {
	return 2
}