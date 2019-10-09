func foobar(x, y) {
	return x(quxbaz())
}

func quxbaz(): never {
	throw new Error()
}