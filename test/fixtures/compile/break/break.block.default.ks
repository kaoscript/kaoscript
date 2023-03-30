func foobar(test) {
	block addArgument {
		if test() {
			break addArgument
		}
	}
}