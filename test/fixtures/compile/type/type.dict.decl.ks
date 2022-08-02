func foobar(x: String, y: Number, z: Boolean) {
	var xyz = {
		x
		y
		z
	}

	return {
		x: `\(xyz.x)`
		y: xyz.y + 42
		z: !xyz.z
	}
}