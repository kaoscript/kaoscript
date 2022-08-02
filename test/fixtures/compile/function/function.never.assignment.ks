func foobar() {
	var dyn a

	a = quxbaz()
}

func quxbaz(): never {
	throw new Error()
}