struct Point {
	x: Number
	y: Number
}

func foobar(xy: Point): { xy: Array<Point> } {
	return {
		xy
	}
}