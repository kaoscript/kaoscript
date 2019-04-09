enum Qux {
	abc
	def
	ghi
}

func foobar(x, y, filter) {
	if const z = filter(x, y, Qux::abc) {
		return z
	}

	return x + y
}