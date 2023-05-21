extern {
	func quxbaz
}

func foobar(value?) {
	return value
		|>?	quxbaz
		|>	[_, _]
}