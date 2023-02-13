extern console

struct Point {
    x: Number
    y: Number
}

struct Point3D extends Point {
	z: Number
}

var dyn point = new Point3D(
	x: 0.3
	y: 0.4
	z: 0.5
)

console.log(point.x + 1, point.y + 2, point.z + 3)

export Point, Point3D