extern console

class Point {
	x: Number
    y: Number
	constructor(@x, @y)
}

func foobar(points: Array<Point>) {
	return points[0]?.x
}