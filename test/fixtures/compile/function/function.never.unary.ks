func foobar(x, y) {
	return !quxbaz()
}

func quxbaz(): never {
	throw Error.new()
}