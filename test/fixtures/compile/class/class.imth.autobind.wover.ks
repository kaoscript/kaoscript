class Foobar {
	foobar() => []
	foobar(x) => [x]
	quxbaz() => []
	quxbaz(x) => [x]
}

func foobar(f: Foobar, test: Boolean) {
	var fn = test ? f.foobar : f.quxbaz
}