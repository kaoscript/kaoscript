func foobar(x) {
	return 1
}
func foobar(x: String) {
	return 2
}
func foobar(x: Number) {
	return 3
}

func quxbaz(y) {
	foobar(y)
}