class Foobar {
}
class Quxbaz {
}

func foobar(a, b: Object, c: Foobar, d: Quxbaz) {
	return a
}
func foobar(a: String, b, c: Object, d: Quxbaz) {
	return b
}
func foobar(a, b, c: Object, d: Quxbaz) {
	return c
}