class Foobar {
	foobar(items) {
		@quxbaz(...items:&(String[]))
	}
	quxbaz(values: String) => 0
	quxbaz(...values: String) => 1
}