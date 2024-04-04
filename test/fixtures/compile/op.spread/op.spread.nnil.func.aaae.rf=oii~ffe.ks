func foobar(x, y, z) {
}

func quxbaz(): {x: Number, y: Number} {
	return {x: 0, y: 1}
}

foobar(...quxbaz()!!)