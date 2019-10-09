func foobar() {
	try! quxbaz()
}

func quxbaz(): never {
	throw new Error()
}