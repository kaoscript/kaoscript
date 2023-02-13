extern console

struct Point {
    x: Number
    y: Number
}

var point = new Point(0.3, 0.4)

console.log(point.x + 1, point.x + point.y)

point.x = 3.14

console.log(point.x + 1, point.x + point.y)