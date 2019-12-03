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
func foobar(a, b, c: Dictionary, d: Quxbaz) {
	return c
}