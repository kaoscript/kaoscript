class ClassA {
	foobar() {
	}
	quxbaz() {
		var foobar = this.foobar

		return foobar()
	}
}