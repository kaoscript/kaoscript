#![rules(ignore-misfit)]

extern console

class Foobar {
	foo(x, ...items, y): String => `[\(x), \(items), \(y)]`
}

var x = Foobar.new()

console.log(`\(x.foo())`)

console.log(`\(x.foo(1))`)

console.log(`\(x.foo(1, 2))`)

console.log(`\(x.foo(1, 2, 3))`)

console.log(`\(x.foo(1, 2, 3, 4))`)