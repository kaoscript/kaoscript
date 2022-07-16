func foobar(...{0,3}args) {
	return 0
}
func foobar(...{1,3}values: Number, ...{0,3}args) {
	return 1
}
func foobar(...{1,3}values: Number, ...{0,3}args: String) {
	return 2
}