func foobar(values: String[]?) {
	quxbaz(...values ?? 'foobar')
}

func quxbaz(...values: String) {
}