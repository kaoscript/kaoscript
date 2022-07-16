extern console

class Foo {
	y(x): String => 'fx'
}

class Bar {
	y(x): String => 'bx'
}

func foo(x, y: Foo | Bar) {
	const z = y.y(x)

	console.log(`\(z)`)
}