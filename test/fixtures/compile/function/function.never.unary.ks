func foobar(x, y) {
	return !quxbaz()
}

func quxbaz(): never {
	throw new Error()
}