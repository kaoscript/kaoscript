extern console

func foobar(values) {
	var {x, y}: Object<String> = values

	console.log(`\(x).\(y)`)
}