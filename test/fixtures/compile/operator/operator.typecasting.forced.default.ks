func foobar(): Array {
	return [42]
}

func quxbaz(x: Array<Number>) {
}

quxbaz(foobar() as Array<Number>)
quxbaz(foobar()!!)