extern console

class Hello {
	hello(name: String): String => `Hello \(name).`
}

class Proxy {
	private @component: Hello?

	constructor(@component)

	proxy @component {
		hello
	}
}

var p1 = Proxy.new(Hello.new())
var p2 = Proxy.new(null)

console.log(`\(p1.hello('Joe'))`)
console.log(`\(p2.hello('Joe'))`)

export Proxy