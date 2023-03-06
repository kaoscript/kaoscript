var Foobar = {
	foobar(name, data) {
		return data
	}
	quxbaz(fn, data) {
	}
}

func foobar(name, data) {
	var f = Foobar.foobar^^(name, ^)

	Foobar.quxbaz(f, data)
}