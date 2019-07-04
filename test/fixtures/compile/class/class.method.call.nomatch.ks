extern console

class Foobar {
	foo(x, ...items, y = 42): String => `[\(x), \(items), \(y)]`
}

const x = new Foobar()

console.log(`\(x.foo())`)