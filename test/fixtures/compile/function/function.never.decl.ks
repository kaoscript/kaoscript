func foobar() {
	var a = quxbaz()
}

func quxbaz(): never {
	throw new Error()
}