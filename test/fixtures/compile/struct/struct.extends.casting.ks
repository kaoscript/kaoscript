struct Point {
    x: Number
    y: Number
}

struct Point3D extends Point {
	z: Number	= 0
}

func print({ x, y }: Point) {
}

func foobar(point: Point3D) {
	print(point)
}