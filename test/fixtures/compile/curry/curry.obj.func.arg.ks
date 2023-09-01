var Foobar = {
	foobar: func(name, data) {
		return data
	}
	quxbaz: func(fn, data) {
	}
}

func foobar(name, data) {
	Foobar.quxbaz(Foobar.foobar^^(name, ^), data)
}