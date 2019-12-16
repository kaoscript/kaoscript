func foobar(a: String, b: String) {
	return a
}
func foobar(a: String, b: Number, c: Boolean = false, d: Array) {
	return b
}

func quxbaz(a: String, b: Number, c: Boolean, d: Array) {
	foobar(a, b, c, d)
}