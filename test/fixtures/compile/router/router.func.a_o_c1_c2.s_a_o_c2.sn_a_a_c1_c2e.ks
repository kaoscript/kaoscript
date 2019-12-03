class Foobar {
}
class Quxbaz {
}

func foobar(a, b: Dictionary, c: Foobar, d: Quxbaz) {
	return a
}
func foobar(a: String, b, c: Dictionary, d: Quxbaz) {
	return b
}
func foobar(a: String?, b, c, d: Foobar, e: Quxbaz) {
	return c
}