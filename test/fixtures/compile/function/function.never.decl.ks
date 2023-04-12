func foobar() {
	var a = quxbaz()
}

func quxbaz(): never {
	throw Error.new()
}