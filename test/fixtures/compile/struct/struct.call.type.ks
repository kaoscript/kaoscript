struct Point {
    x: Number
    y: Number
}

func foobar(x: Struct) => 'struct'
func foobar(x: Point) => 'struct-instance'
func foobar(x) => 'any'

var point = Point.new(0.3, 0.4)

foobar(Point)
foobar(point)