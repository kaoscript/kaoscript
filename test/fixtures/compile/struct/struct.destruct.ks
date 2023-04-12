extern console

struct Point {
    x: Number
    y: Number
}

var point = Point.new(0.3, 0.4)

var {x, y} = point

console.log(x + 1, y + 1)