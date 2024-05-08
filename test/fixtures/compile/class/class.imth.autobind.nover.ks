class Foobar {
	foobar() => []
	quxbaz() => []
}

func foobar(f: Foobar, test: Boolean) {
	var fn = if test set f.foobar else f.quxbaz
}