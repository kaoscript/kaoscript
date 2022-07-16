func foobar(x: Number | String | Boolean): Number {
	return quxbaz(x)
}

func quxbaz(x: Number): Number {
	return 1
}
func quxbaz(x: String): Number {
	return 2
}
func quxbaz(x: Boolean, y: Number = 0): Number {
	return 3
}