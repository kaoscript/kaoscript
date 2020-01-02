type NS = Number | String

func foobar(x: NS) {
	quxbaz(x)
}

func quxbaz(x: Number) {
	return 1
}
func quxbaz(x: String) {
	return 2
}