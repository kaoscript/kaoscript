extern console

func foobar(values) {
	var {x, y}: {x: String, y: String} = values

	console.log(`\(x).\(y)`)
}