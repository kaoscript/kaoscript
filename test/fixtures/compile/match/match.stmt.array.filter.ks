extern console

var dyn somePoint = [1, 1]

match somePoint {
	with [x, y] when x == 0 && y == 0					=> console.log(`(0, 0) is at the origin`)
	with [x, y] when y == 0								=> console.log(`(\(x), 0) is on the x-axis`)
	with [x, y] when x == 0								=> console.log(`(0, \(y)) is on the y-axis`)
	with [x, y] when -2 <= x <= 2 && -2 <= y <= 2		=> console.log(`(\(x), \(y)) is inside the box`)
	with [x, y]											=> console.log(`(\(x), \(y)) is outside of the box`)
	else												=> console.log(`Not a point`)
}