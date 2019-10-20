#![target(ecma-v5)]

extern console

func foobar([x, y]: Array<String>) {
	console.log(`\(x).\(y)`)
}