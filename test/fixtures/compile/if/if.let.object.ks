extern console

func foobar() => {
	x: 1
	y: 2
}

if let {x, y} = foobar() {
	console.log(`\(x)`)
}