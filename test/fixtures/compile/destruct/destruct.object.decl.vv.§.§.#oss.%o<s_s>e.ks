extern console

func foobar(values: {x: String, y: String}) {
	var {x, y}: String{} = values

	console.log(`\(x).\(y)`)
}