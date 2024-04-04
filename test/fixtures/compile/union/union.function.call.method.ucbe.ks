class Foobar {
	foobar(x: Foobar)
}

func quxbaz(): Foobar | Boolean {
	return false
}

func waldo(x: Foobar) {
	quxbaz().foobar(x)
}