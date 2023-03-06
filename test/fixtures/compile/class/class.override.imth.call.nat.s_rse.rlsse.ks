class Foobar {
	foobar(items) {
		this.quxbaz(...(items as String[]))
	}
	quxbaz(values: String) => 0
	quxbaz(...values: String) => 1
}