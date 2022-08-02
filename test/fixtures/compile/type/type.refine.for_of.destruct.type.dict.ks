type Coord = {
	x: Number
	y: Number
	z: Number
}

func foobar(values: Dictionary<Coord>) {
	var mut r = 0

	for var {x, y, z} of values {
		r += (x * y) /. z
	}

	return r
}