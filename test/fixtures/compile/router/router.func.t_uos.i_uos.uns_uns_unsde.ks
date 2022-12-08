func foobar(x: Date, y: Object | String) {
	return 0
}
func foobar(x: Number, y: Object | String) {
	return 1
}
func foobar(x: Number | String, y: Number | String, z: Number | String = 0) {
	return 2
}