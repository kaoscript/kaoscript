func foobar(): { foobar(): String } {
	return {
		foobar() {
			return ''
		}
	}
}