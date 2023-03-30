extern console

func foobar({x, y, ...values}: String{}) {
	console.log(`\(x).\(y)`)
}

export foobar