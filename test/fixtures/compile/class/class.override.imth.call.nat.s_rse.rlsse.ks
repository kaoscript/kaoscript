class Foobar {
	foobar(items) {
		this.quxbaz(...items:&(String[]))
	}
	quxbaz(values: String) => 0
	quxbaz(...values: String) => 1
}