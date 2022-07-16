func foobar(...args: Number | String) {
	return 0
}
func foobar(...args: Number | String, flag: Boolean) {
	return 1
}

foobar(0, [], false)