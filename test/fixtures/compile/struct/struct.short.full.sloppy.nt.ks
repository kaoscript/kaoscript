extern console

struct Point {
    x: Number
    y: Number
}

func foobar(x, y) {
	const point = Point(y, x)
	
	console.log(point.x + 1, point.x + point.y)
}