func foobar(): { foobar(x: String): String } {
	return {
		foobar(x) => x
	}
}