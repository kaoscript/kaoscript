require {
	func quxbaz()
}

func foobar(test) {
	return quxbaz()
		..foobar()
}