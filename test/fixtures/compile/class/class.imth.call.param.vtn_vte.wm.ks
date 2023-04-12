#![rules(ignore-misfit)]

extern console

class Foobar {
	foo(x: Number? = null, y: String): String => `[\(x), \(y)]`
}

var x = Foobar.new()

console.log(`\(x.foo())`)

console.log(`\(x.foo(1))`)

console.log(`\(x.foo('foo'))`)

console.log(`\(x.foo(1, 'foo'))`)

console.log(`\(x.foo('foo', 'bar'))`)