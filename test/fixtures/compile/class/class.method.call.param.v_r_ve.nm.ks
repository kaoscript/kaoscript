extern console

class Foobar {
	foo(x, ...items, y): String => `[\(x), \(items), \(y)]`
}

const x = new Foobar()

console.log(`\(x.foo(1, 2))`)

console.log(`\(x.foo(1, 2, 3))`)

console.log(`\(x.foo(1, 2, 3, 4))`)