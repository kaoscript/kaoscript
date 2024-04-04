func foobar(x, y, z) {
}

func quxbaz(): [Number, Number, Number] {
	return [0, 1, 2]
}

foobar(...quxbaz()!!)