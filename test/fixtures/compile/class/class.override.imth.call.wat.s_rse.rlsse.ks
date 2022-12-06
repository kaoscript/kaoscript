class Foobar {
	foobar(items) {
		@quxbaz(...(items as String[]))
	}
	quxbaz(values: String)
	quxbaz(...values: String)
}