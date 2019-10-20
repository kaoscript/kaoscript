#![target(ecma-v5)]

extern console

func foobar([x, y]: [String, String]) {
	console.log(`\(x).\(y)`)
}