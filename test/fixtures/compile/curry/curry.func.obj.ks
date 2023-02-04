var Foobar = {
	foobar(name, data) {
		return data
	}
	quxbaz(fn, data) {
	}
}

func foobar(name, data) {
	Foobar.quxbaz(Foobar.foobar^^(name), data)
}