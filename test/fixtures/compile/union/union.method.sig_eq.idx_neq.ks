extern console

class Foo {
	y(x): String => 'fx'
}

class Bar {
	y()
	y(x): String => 'bx'
}

func foo(x, y: Foo | Bar) {
	var z = y.y(x)

	console.log(`\(z)`)
}