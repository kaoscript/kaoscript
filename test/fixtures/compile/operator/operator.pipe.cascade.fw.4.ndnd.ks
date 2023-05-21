extern {
	func quxbaz
	func corge
	func grault
	func waldo
}

func foobar(value?) {
	return value
		|>?	quxbaz
		|>	corge
		|>?	grault
		|>	waldo
}