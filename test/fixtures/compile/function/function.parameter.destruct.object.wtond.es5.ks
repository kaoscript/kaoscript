#![target(ecma-v5)]

extern console

func foobar({x, y}: {x: String, y: String}) {
	console.log(`\(x).\(y)`)
}