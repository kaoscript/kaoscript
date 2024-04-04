func foobar(x) {
	var mut y = 0
	var mut z = null

	if x == 0 {
		z = 1
	}

	y = z:!!(Any)
}