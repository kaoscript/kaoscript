func foobar(x, y, z) {
}

func quxbaz() {
	return {x: 0, y: 1, z: 2}
}

foobar(...quxbaz()!!)