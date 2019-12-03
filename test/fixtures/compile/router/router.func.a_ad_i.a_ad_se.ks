func foobar(x, y = 0, z: Number) {
	return x.times(y + z)
}
func foobar(x, y = 0, z: String) {
	return x.times(y) + z
}