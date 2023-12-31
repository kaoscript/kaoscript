class Point {
	x: Number
	y: Number
	constructor(@x, @y)
}

class Point3D extends Point {
	z: Number
	constructor(@x, @y, @z) {
		super(x, y)
	}
}

func foobar(p: Point3D) {
	var d3 = p:&?(Point)

	echo(d3.x + 1, d3.y + 2)
}