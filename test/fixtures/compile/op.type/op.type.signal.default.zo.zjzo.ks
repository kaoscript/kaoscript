type Point = {
	x: Number
	y: Number
}

type Point3D = Point & {
	z: Number
}

func foobar(p: Point) {
	var d3 = p:!(Point3D)

	echo(d3.x + 1, d3.y + 2, d3.z + 3)
}