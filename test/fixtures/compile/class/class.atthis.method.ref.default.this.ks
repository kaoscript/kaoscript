class ClassA {
	foobar() {
	}
	quxbaz() {
		const foobar = this.foobar

		return foobar()
	}
}