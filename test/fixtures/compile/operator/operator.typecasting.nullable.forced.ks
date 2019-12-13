func foobar(): Number? {
	return 42
}

func quxbaz(x: Number) {
}

quxbaz(foobar() as! Number)
quxbaz(foobar()!?)