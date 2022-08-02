enum Qux {
	abc
	def
	ghi
}

func foobar(x, y, filter) {
	if var z = filter(x, y, Qux::abc) {
		return z
	}

	return x + y
}