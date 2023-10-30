class Foobar {
	foobar(items) {
		if items is Array {
			this.quxbaz(...items)
		}
		else {
			this.quxbaz(items)
		}
	}
	quxbaz(values: String)
	quxbaz(...values: String)
}