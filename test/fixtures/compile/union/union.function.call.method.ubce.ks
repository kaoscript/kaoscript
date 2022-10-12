class Foobar {
	foobar(x: Foobar)
}

func quxbaz(): Boolean | Foobar {
	return false
}

func waldo(): Boolean | Foobar {
	return false
}

quxbaz().foobar(waldo()!!)