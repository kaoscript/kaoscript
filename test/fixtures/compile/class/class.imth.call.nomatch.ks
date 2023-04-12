extern console

class Foobar {
	foo(x, ...items, y = 42): String => `[\(x), \(items), \(y)]`
}

var x = Foobar.new()

console.log(`\(x.foo())`)