class Foobar {
	foobar(x: String, y: String, *options) {
		return 1
	}
}

func foobar(x, y) {
	var f = new Foobar()

	f.foobar(x, y, options: {})
}