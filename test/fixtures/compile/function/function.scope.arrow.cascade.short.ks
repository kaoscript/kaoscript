func foobar(this) {
	return {
		value: () => () => this.value()
	}
}