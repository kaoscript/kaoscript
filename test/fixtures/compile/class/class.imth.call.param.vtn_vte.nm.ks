extern console

class Foobar {
	foo(x: Number? = null, y: String): String => `[\(x), \(y)]`
}

var x = Foobar.new()

console.log(`\(x.foo('foo'))`)

console.log(`\(x.foo(1, 'foo'))`)