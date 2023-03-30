func foobar(point) {
	match point {
		[0, 0]			=> echo(`(0, 0) is at the origin`)
		[_, 0]			=> echo(`(\(somePoint[0]), 0) is on the x-axis`)
		[0, _]			=> echo(`(0, \(somePoint[1])) is on the y-axis`)
		[-2..2, -2..2]	=> echo(`(\(somePoint[0]), \(somePoint[1])) is inside the box`)
		[_, _]			=> echo(`(\(somePoint[0]), \(somePoint[1])) is outside of the box`)
		else			=> echo(`Not a point`)
	}
}