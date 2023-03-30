extern console

struct Foobar {
	x: String
	y: String
}

func foobar({x: Number, y: Number}: Foobar) {
	console.log(`\(x).\(y)`)
}