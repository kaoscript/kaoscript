extern console

class Foo {
	y(x): Boolean => false
}

class Bar {
	y()
	y(x): Number => 42
}

func foo(x, y: Foo | Bar) {
	var z = y.y(x)

	console.log(`\(z)`)
}