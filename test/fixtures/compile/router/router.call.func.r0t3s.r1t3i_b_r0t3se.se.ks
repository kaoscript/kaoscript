func foobar(...{0,3}args: String) {
	return 0
}
func foobar(...{1,3}values: Number, flag: Boolean, ...{0,3}args: String) {
	return 1
}

foobar('x')