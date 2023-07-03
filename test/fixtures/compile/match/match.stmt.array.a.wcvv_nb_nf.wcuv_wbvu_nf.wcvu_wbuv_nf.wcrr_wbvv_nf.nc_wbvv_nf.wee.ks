func foobar(point) {
	match point {
		[0, 0]							=> echo(`(0, 0) is at the origin`)
		[_, 0]			with var [x, _]	=> echo(`(\(x), 0) is on the x-axis`)
		[0, _]			with var [_, y]	=> echo(`(0, \(y)) is on the y-axis`)
		[-2..2, -2..2]	with var [x, y]	=> echo(`(\(x), \(y)) is inside the box`)
						with var [x, y]	=> echo(`(\(x), \(y)) is outside of the box`)
		else							=> echo(`Not a point`)
	}
}