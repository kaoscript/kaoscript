func foobar() {
	const a = quxbaz()
}

func quxbaz(): never {
	throw new Error()
}