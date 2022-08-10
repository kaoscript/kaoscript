extern console

class Hello {
	hello(name: String): String => `Hello \(name).`
}

class Proxy {
	private @component: Hello?

	constructor(@component)

	alias hello = @component.hello
}

var p1 = new Proxy(new Hello())
var p2 = new Proxy(null)

console.log(`\(p1.hello('Joe'))`)
console.log(`\(p2.hello('Joe'))`)

export Proxy