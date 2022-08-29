extern console

func foobar() => {
	x: 1
	y: 2
}

if var {x, y} ?= foobar() {
	console.log(`\(x)`)
}