func foobar(): never {
	quxbaz()
}

func quxbaz(): never {
	throw Error.new()
}