class Foobar {
	foobar(x: Foobar)
}

class Foobar2 {
	foobar()
	foobar(x: Foobar)
}

func quxbaz(): Foobar | Foobar2 {
	return Foobar.new()
}

func waldo(x: Foobar) {
	quxbaz().foobar(x)
}