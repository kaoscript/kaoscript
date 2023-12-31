struct Point {
	x: Number
	y: Number
}

struct Point3D extends Point {
	z: Number
}

func foobar(p) {
	if var d3 ?= p:>?(Point | Point3D) {
		echo(d3.x + 1, d3.y + 2)
	}
}