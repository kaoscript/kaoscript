#![target(ecma-v5)]

extern console

func foobar({x, y}: Dictionary<String> = {x: 'foo', y: 'bar'}) {
	console.log(`\(x).\(y)`)
}