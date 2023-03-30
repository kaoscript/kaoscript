extern console

func foobar(values: {x: String, y: String}) {
	var {x, y} = values

	console.log(`\(x).\(y)`)
}