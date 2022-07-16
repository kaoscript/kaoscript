func foobar(x: Number | String): Number {
	return quxbaz(x)
}

func quxbaz(x: Number | String): String {
	return '1'
}
func quxbaz(x: String, y: Number = 0): Number {
	return 2
}
func quxbaz(x: Number, y: Number = 0): Number {
	return 3
}