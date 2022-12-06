class Foobar {
	foobar(items) {
		@quxbaz(...(items as Array<String>))
	}
	quxbaz(values: String)
	quxbaz(...values: String)
}