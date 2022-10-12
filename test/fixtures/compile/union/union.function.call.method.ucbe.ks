class Foobar {
	foobar(x: Foobar)
}

func quxbaz(): Foobar | Boolean {
	return false
}

func waldo(): Foobar | Boolean {
	return false
}

quxbaz().foobar(waldo()!!)