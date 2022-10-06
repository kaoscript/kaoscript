class Foobar {
	static foobar(x: String, y: String, *options) {
		return 1
	}
}

func foobar(x, y) {
	Foobar.foobar(x, y, options: {})
}