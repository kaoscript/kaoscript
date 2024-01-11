type Coord = {
	x: Number
	y: Number
}

func foobar({ x, y } & first: Coord, last: Coord = first) {
}