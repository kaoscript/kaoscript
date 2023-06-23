func foobar(this) {
	return {
		value() {
			return () => this.value()
		}
	}
}