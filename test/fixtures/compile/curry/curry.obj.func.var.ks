var Foobar = {
	foobar: func(name, data) {
		return data
	}
	quxbaz: func(fn, data) {
	}
}

func foobar(name, data) {
	var f = Foobar.foobar^^(name, ^)

	Foobar.quxbaz(f, data)
}