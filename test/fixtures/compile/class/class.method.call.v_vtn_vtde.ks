extern console

class Foobar {
	foo(x: String, y: String = null, z: Boolean = false): String => `[\(x), \(y), \(z)]`
}

const x = new Foobar()


console.log(`\(x.foo('foo'))`)

console.log(`\(x.foo('foo', 'bar'))`)

console.log(`\(x.foo('foo', true))`)

console.log(`\(x.foo('foo', 'bar', true))`)