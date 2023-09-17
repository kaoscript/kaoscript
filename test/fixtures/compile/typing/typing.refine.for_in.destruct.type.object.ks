type Coord = {
	x: Number
	y: Number
	z: Number
}

func foobar(values: Array<Coord>) {
	var mut r = 0

	for var {x, y, z} in values {
		r += (x * y) /. z
	}

	return r
}