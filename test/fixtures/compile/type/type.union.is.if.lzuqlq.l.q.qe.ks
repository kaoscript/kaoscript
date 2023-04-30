struct Point {
	x: Number
	y: Number
}

type Foobar = Point | Array<Point>

func foobar(values: Foobar[]) {
	for var value in values {
		if value is Array {
			for var vv in value {
				quxbaz(vv)
			}
		}
		else {
			quxbaz(value)
		}
	}
}

func quxbaz(value: Point) {
}