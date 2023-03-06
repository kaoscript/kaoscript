func foobar(this) {
	this.foobar = true

	return () => {
		this.arrow = true

		return this
	}
}

echo(foobar*$({})())