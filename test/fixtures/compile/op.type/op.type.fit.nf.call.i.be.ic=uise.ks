func foobar(): Number | String {
	return 42
}

func quxbaz(x: Number) {
	return 0
}
func quxbaz(x: Boolean) {
	return 1
}

quxbaz(foobar()!!)