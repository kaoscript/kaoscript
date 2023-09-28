func foobar(foo?, bar?) {
	quxbaz(foo ?? ...bar ?? 'quxbaz')
}

func quxbaz(...values) {
}