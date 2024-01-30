func foobar(x: Number, y: Number, z: Number?) {
	var result = {
		x
	}

	if x == 0 {
		result.y = y
	}

	result.z = z
}