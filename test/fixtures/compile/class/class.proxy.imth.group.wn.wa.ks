extern console

class Hello {
	hello(name: String): String => `Hello \(name).`
}

class Proxy {
	public @component

	proxy @component {
		hello
	}
}

var p1 = Proxy.new()
var p2 = Proxy.new()

p1.component = Hello.new()

console.log(`\(p1.hello('Joe'))`)
console.log(`\(p2.hello('Joe'))`)

export Proxy