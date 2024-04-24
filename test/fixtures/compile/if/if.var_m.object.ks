extern console

func foobar() => {
	x: 1
	y: 2
}

if var mut {x, y} ?= foobar() {
	console.log(`\(x)`)
}