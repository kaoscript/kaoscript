extern console

struct Point {
    x: Number
    y: Number
}

func foobar(x, y) {
	var point = Point.new(y: y, x: x)

	console.log(point.x + 1, point.x + point.y)
}