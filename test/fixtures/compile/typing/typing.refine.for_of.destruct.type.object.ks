type Coord = {
	x: Number
	y: Number
	z: Number
}

func foobar(values: Object<Coord>) {
	var mut r = 0

	for var {x, y, z} of values {
		r += (x * y) /# z
	}

	return r
}