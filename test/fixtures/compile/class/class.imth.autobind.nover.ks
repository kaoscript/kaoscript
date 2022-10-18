class Foobar {
	foobar() => []
	quxbaz() => []
}

func foobar(f: Foobar, test: Boolean) {
	var fn = test ? f.foobar : f.quxbaz
}