func foobar(): Number | String {
	return 42
}

func quxbaz(x: Number, y: Number) {
	return 0
}
func quxbaz(x: Boolean, y: Boolean) {
	return 1
}

quxbaz(0, foobar()!!)