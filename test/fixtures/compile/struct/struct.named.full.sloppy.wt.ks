extern console

struct Point {
    x: Number
    y: Number
}

var point = Point(y: 0.4, x: 0.3)

console.log(point.x + 1, point.x + point.y)