func foobar(point) {
	match point {
		[0, 0]						=> echo(`(0, 0) is at the origin`)
		[_, 0]		with var [x, _]	=> echo(`(\(x), 0) is on the x-axis`)
	}
}