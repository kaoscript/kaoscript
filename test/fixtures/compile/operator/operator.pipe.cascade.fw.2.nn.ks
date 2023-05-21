extern {
	func quxbaz
	func corge
}

func foobar(value?) {
	return value
		|>?	quxbaz
		|>?	corge
}