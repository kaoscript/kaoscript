func foobar(point) {
	match point {
		[0, _]			with [_, y]	=> echo(`(0, \(y)) is on the y-axis`)
	}
}