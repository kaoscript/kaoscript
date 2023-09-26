struct Point {
    x: Number
    y: Number
}

struct Point3D extends Point {
	z: Number
}

var dyn point = Point3D.new(0.3, 0.4, 0.5)

echo(point.x + 1, point.y + 2, point.z + 3)

export Point, Point3D