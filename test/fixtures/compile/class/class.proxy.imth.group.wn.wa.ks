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

var p1 = new Proxy()
var p2 = new Proxy()

p1.component = new Hello()

console.log(`\(p1.hello('Joe'))`)
console.log(`\(p2.hello('Joe'))`)

export Proxy