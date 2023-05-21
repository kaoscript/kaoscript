extern {
	func quxbaz
}

func foobar(value?) {
	return value
		|>?	quxbaz
		|>	[0]
}