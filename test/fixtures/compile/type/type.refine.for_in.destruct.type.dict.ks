type Coord = {
	x: Number
	y: Number
	z: Number
}

func foobar(values: Array<Coord>) {
	auto r = 0

	for const {x, y, z} in values {
		r += (x * y) /. z
	}

	return r
}