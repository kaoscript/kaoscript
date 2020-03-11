type Coord = {
	x: Number
	y: Number
	z: Number
}

func foobar(values: Dictionary<Coord>) {
	auto r = 0

	for const {x, y, z} of values {
		r += (x * y) /. z
	}

	return r
}