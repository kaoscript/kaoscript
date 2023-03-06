class Foobar {
	foobar(items) {
		@quxbaz(...(items as String[]))
	}
	quxbaz(values: String) => 0
	quxbaz(...values: String) => 1
}