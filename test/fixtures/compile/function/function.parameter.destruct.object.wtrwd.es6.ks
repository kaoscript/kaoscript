extern console

func foobar({x, y}: Dictionary<String> = {x: 'foo', y: 'bar'}) {
	console.log(`\(x).\(y)`)
}