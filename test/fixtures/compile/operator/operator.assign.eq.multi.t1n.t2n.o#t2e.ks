type Point2D = {
	x: Number
	y: Number
}

type Point3D = {
	x: Number
	y: Number
	z: Number
}

func foobar() {
	var mut d2: Point2D? = null
	var mut d3: Point3D? = null

	d2 = d3 = { x: 0, y: 0, z: 0 }
}