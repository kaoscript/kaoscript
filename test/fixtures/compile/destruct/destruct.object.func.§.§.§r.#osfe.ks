extern console

func foobar({x, y, ...values}: Object<String>) {
	console.log(`\(x).\(y)`)
}