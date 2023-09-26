extern console

struct Point {
	x: Number
	y: Number
}

struct Point3D extends Point {
	z: Number
}

func foobar(p) {
	var d3 = p as! Point3D

	console.log(d3.x + 1, d3.y + 2, d3.z + 3)
}