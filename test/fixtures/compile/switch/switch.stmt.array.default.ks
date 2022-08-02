extern console

var dyn somePoint = [1, 1]

switch somePoint {
	[0, 0]			=> console.log(`(0, 0) is at the origin`)
	[_, 0]			=> console.log(`(\(somePoint[0]), 0) is on the x-axis`)
	[0, _]			=> console.log(`(0, \(somePoint[1])) is on the y-axis`)
	[-2..2, -2..2]	=> console.log(`(\(somePoint[0]), \(somePoint[1])) is inside the box`)
	[_, _]			=> console.log(`(\(somePoint[0]), \(somePoint[1])) is outside of the box`)
					=> console.log(`Not a point`)
}