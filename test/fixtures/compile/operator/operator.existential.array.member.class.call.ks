class Point {
	private {
		@x: Number
		@y: Number
	}
	constructor(@x, @y)
	x(): @x
}

func foobar(points: Array<Point>) {
	return points[0]?.x()
}