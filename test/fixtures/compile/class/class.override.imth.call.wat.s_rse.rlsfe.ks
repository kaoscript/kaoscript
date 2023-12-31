class Foobar {
	foobar(items) {
		@quxbaz(...items:&(Array<String>))
	}
	quxbaz(values: String)
	quxbaz(...values: String)
}