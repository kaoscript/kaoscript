extern console

class Foo {
	y(x: Boolean): String => 'fx'
}

class Bar {
	y(x: Number): String => 'bx'
}

func foo(x, y: Foo | Bar) {
	const z = y.y(x)

	console.log(`\(z)`)
}