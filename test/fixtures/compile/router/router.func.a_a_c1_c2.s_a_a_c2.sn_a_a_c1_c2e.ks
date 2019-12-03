class Foobar {
}
class Quxbaz {
}

func foobar(a, b, c: Foobar, d: Quxbaz) {
	return a
}
func foobar(a: String, b, c, d: Quxbaz) {
	return b
}
func foobar(a: String?, b, c, d: Foobar, e: Quxbaz) {
	return c
}