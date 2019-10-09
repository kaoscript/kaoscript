func foobar(): never {
	quxbaz()
}

func quxbaz(): never {
	throw new Error()
}