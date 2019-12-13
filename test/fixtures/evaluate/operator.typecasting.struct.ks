require expect: func

struct Point {
	x: Number
	y: Number
}

struct Point3D extends Point {
	z: Number
}

const p2 = Point(1, 2)
const p3 = Point3D(1, 2, 3)

func default(p: Point): Number {
	const d3 = p as Point3D

	return d3.x + d3.y + d3.z
}

expect(() => default(p2)).to.throw('The given value can\'t be casted as a "Point3D"')
expect(default(p3)).to.equal(6)

func nullable(p: Point): Number {
	if const d3 = p as? Point3D {
		return d3.x + d3.y + d3.z
	}
	else {
		return 0
	}
}

expect(nullable(p2)).to.equal(0)
expect(nullable(p3)).to.equal(6)