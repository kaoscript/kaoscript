extern console

struct Point {
    x: Number
    y: Number
}

struct Point3D extends Point {
	z: Number
}

let point = Point3D(0.3, 0.4, 0.5)

console.log(point.x + 1, point.y + 2, point.z + 3)

export Point, Point3D