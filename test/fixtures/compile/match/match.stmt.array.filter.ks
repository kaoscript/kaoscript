func foobar(point) {
	match point {
		with [x, y] when x == 0 && y == 0					=> echo(`(0, 0) is at the origin`)
		with [x, y] when y == 0								=> echo(`(\(x), 0) is on the x-axis`)
		with [x, y] when x == 0								=> echo(`(0, \(y)) is on the y-axis`)
		with [x, y] when -2 <= x <= 2 && -2 <= y <= 2		=> echo(`(\(x), \(y)) is inside the box`)
		with [x, y]											=> echo(`(\(x), \(y)) is outside of the box`)
		else												=> echo(`Not a point`)
	}
}