type Point = {
	x: Number
	y: Number
}

type Point3D = Point & {
	z: Number
}

func foobar(p: Point3D) {
	if var d3 ?= p:&?(Point) {
		echo(d3.x + 1, d3.y + 2)
	}
}