type Point = {
	x: Number
	y: Number
}

struct Point3D {
	x: Number
	y: Number
	z: Number
}

func foobar(p) {
	var d3 = p:>?(Point | Point3D)

	if d3 != null {
		echo(d3.x + 1, d3.y + 2)
	}
}