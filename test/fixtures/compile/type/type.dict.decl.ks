func foobar(x: String, y: Number, z: Boolean) {
	const xyz = {
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