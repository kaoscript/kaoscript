func foobar() {
	try! quxbaz()
}

func quxbaz(): never {
	throw Error.new()
}