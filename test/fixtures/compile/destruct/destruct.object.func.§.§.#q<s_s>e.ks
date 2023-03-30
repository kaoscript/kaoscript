extern console

struct Foobar {
	x: String
	y: String
}

func foobar({x, y}: Foobar) {
	console.log(`\(x).\(y)`)
}