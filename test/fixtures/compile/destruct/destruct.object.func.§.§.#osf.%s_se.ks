extern console

func foobar({x, y}: Object<String> = {x: 'foo', y: 'bar'}) {
	console.log(`\(x).\(y)`)
}