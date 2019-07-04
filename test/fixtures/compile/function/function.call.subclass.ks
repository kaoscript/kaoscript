extern console

class Point2D {
	private {
		_x: Number
		_y: Number
	}
	constructor(@x, @y)
	x() => @x
	y() => @y
}

class Point3D extends Point2D {
	private {
		_z: Number
	}
	constructor(@x, @y, @z) {
		super(x, y)
	}
	z() => @z
}

func x(point: Point2D) => point.x()

const p = new Point3D(1, 2, 3)

console.log(x(p))