func foobar() {
	let a

	a = quxbaz()
}

func quxbaz(): never {
	throw new Error()
}