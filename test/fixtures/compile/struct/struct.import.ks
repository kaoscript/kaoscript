extern console

import './struct.export'

const point = Point(0.3, 0.4)

console.log(point.x + 1, point.x + point.y)

export Point