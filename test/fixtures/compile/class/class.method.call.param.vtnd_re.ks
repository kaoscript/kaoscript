extern console

class Foobar {
	foo(x: Number = null, ...items): String => `[\(x), \(items)]`
}

const x = new Foobar()

console.log(`\(x.foo())`)

console.log(`\(x.foo(1))`)

console.log(`\(x.foo('foo'))`)

console.log(`\(x.foo(1, 2))`)

console.log(`\(x.foo('foo', 1))`)