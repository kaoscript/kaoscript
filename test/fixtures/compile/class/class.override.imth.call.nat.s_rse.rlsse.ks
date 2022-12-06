class Foobar {
	foobar(items) {
		this.quxbaz(...(items as String[]))
	}
	quxbaz(values: String)
	quxbaz(...values: String)
}