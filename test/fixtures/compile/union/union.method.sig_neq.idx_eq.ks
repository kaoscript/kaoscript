extern console

class Foo {
	y(x): Boolean => false
}

class Bar {
	y(x): Number => 42
}

func foo(x, y: Foo | Bar) {
	const z = y.y(x)

	console.log(`\(z)`)
}