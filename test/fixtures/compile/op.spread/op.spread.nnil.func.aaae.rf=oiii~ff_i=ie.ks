func foobar(x, y, z) {
}

func quxbaz(): {x: Number, y: Number, z: Number} {
	return {x: 0, y: 1, z: 2}
}

foobar(...quxbaz()!!, 3)