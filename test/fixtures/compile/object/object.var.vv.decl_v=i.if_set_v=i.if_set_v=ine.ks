func foobar(x: Number, y: Number, z: Number?) {
	var result = {
		x
	}

	if x == 0 {
		result.y = y
	}

	if x == 1 {
		result.z = z
	}
}