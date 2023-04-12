func foobar(x, y) {
	return x + y + quxbaz()
}

func quxbaz(): never {
	throw Error.new()
}