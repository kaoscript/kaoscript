extern console

struct Point {
    x: Number
    y: Number
}

var point = Point.new(x: 0.3, y: 0.4)

console.log(point.x + 1, point.x + point.y)