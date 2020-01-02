type NS = Number | String

func foobar() {
	return 0
}
func foobar(x: NS = 0, y: NS = 0) {
	return 1
}
func foobar(x: NS = 0, y: NS = 0, z: String | RegExp) {
	return 2
}