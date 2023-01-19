func foobar(values, _3d) {
	var point = {
		x: 1
		y: 1
		...values if _3d
	}

	return point
}