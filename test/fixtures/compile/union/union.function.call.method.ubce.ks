class Foobar {
	foobar(x: Foobar)
}

func quxbaz(): Boolean | Foobar {
	return false
}

func waldo(x: Foobar) {
	quxbaz().foobar(x)
}