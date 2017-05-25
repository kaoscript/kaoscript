class Point2D {
	private {
		_x: Number
		_y: Number
	}
	constructor(@x, @y)
}

class Point3D extends Point2D {
	private {
		_z: Number
	}
	constructor(@x, @y, @z) {
		super(x, y)
	}
}

const p = new Point3D(1, 2)