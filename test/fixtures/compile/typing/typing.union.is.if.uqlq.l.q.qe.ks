struct Point {
	x: Number
	y: Number
}

func foobar(values: Point | Array<Point>) {
	if values is Array {
		for var value in values {
			quxbaz(value)
		}
	}
	else {
		quxbaz(values)
	}
}

func quxbaz(value: Point) {
}