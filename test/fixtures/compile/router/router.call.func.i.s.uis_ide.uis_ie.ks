func foobar(x: Number | String, y: Number): String {
	return quxbaz(x, y)
}

func quxbaz(x: Number): Number {
	return 1
}
func quxbaz(x: String): Number {
	return 2
}
func quxbaz(x: Number | String, y: Number = 0): String {
	return '3'
}