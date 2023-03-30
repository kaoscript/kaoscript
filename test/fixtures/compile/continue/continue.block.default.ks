func foobar(test) {
	block addArgument {
		if test() {
			continue addArgument
		}
	}
}