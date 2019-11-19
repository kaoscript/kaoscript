extern console

struct Point {
    x: Number
    y: Number
}

const point = Point(0.3, 0.4)

const {x, y} = point

console.log(x + 1, y + 1)