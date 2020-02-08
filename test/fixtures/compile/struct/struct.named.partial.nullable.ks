extern console

struct Point {
    x: Number?
    y: Number?
}

const point = Point(y: 0.4)

console.log(point.x + 1, point.x + point.y)