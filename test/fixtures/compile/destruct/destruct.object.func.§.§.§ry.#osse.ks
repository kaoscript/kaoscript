extern console

func foobar({x, y, ...}: String{}) {
	console.log(`\(x).\(y)`)
}

export foobar