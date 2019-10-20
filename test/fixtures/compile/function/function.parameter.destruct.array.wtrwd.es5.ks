#![target(ecma-v5)]

extern console

func foobar([x, y]: Array<String> = ['foo', 'bar']) {
	console.log(`\(x).\(y)`)
}