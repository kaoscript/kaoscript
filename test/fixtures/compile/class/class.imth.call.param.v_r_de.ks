extern console

class Foobar {
	foo(x, ...items, y = 42): String => `[\(x), \(items), \(y)]`
}

var x = new Foobar()

console.log(`\(x.foo(1))`)

console.log(`\(x.foo(1, 2))`)

console.log(`\(x.foo(1, 2, 3, 4))`)