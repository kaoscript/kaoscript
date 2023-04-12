extern console

import './struct.export'

var point = Point.new(0.3, 0.4)

console.log(point.x + 1, point.x + point.y)

export Point