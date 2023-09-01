func foobar(): { foobar(x: String): String } {
	return {
		foobar: func(x) => x
	}
}