extern console

struct Foobar {
	x: String
	y: String
}

func foobar(values: Foobar) {
	var {x, y} = values

	console.log(`\(x).\(y)`)
}