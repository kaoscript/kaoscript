func foobar(x: Number | String) {
	quxbaz(x)
}

func quxbaz(x: Number) {
	return 1
}
func quxbaz(x: String) {
	return 2
}