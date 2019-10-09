func foobar(x, y) {
	return x + y + quxbaz()
}

func quxbaz(): never {
	throw new Error()
}