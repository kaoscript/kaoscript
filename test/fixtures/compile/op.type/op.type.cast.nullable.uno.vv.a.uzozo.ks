type Point = {
	x: Number
	y: Number
}

type Point3D = {
	a: Number
	b: Number
	c: Number
}

func foobar(p) {
	var d3 = p:>?(Point | Point3D)

	if d3 != null {
		if d3 is Point {
			echo(d3.x + 1, d3.y + 2)
		}
		else {
			echo(d3.a + 1, d3.b + 2, d3.c + 3)
		}
	}
}