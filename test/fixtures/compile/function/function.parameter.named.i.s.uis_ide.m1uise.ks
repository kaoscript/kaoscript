func foobar(value: Number | String): Number {
	return quxbaz(x: value)
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