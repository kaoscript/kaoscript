func foobar(x: Number | String): Number {
	return quxbaz(x)
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