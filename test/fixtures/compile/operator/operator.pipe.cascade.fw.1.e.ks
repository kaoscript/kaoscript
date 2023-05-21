extern {
	func quxbaz
}

func foobar(value?) {
	return value
		|>#	quxbaz
}