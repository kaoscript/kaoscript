type Coord = {
	x: Number
	y: Number
}

func foobar({ x, y } & coord: Coord): Coord {
	return coord
}