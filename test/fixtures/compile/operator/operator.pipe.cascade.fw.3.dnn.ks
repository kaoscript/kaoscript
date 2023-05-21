extern {
	func quxbaz
	func corge
	func grault
}

func foobar(value?) {
	return value
		|>	quxbaz
		|>?	corge
		|>?	grault
}