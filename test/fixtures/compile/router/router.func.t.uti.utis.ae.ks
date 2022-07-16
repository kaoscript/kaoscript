func foobar(x: Date) {
	return 1
}
func foobar(x: Date | Number) {
	return 2
}
func foobar(x: Date | Number | String) {
	return 3
}
func foobar(x) {
	return 4
}