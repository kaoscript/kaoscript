func foobar(): { foobar(): String } {
	return {
		foobar: func() {
			return 0
		}
	}
}