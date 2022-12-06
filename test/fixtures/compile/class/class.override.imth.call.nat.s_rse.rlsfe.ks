class Foobar {
	foobar(items) {
		this.quxbaz(...(items as Array<String>))
	}
	quxbaz(values: String)
	quxbaz(...values: String)
}