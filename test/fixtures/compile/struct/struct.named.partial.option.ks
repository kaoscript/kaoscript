extern console

struct Point {
    x: Number	= 0
    y: Number	= 0
}

var point = Point(y: 0.4)

console.log(point.x + 1, point.x + point.y)