extern console: {
	log(...args)
}

let somePoint = [1, 1]

switch somePoint {
	[0, 0]			=> console.log(`(0, 0) is at the origin`)
	[, 0]			=> console.log(`(\(somePoint[0]), 0) is on the x-axis`)
	[0,]			=> console.log(`(0, \(somePoint[1])) is on the y-axis`)
	[-2..2, -2..2]	=> console.log(`(\(somePoint[0]), \(somePoint[1])) is inside the box`)
	[,]				=> console.log(`(\(somePoint[0]), \(somePoint[1])) is outside of the box`)
					=> console.log(`Not a point`)
}