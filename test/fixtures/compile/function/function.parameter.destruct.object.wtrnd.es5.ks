#![target(ecma-v5)]

extern console

func foobar({x, y}: Dictionary<String>) {
	console.log(`\(x).\(y)`)
}