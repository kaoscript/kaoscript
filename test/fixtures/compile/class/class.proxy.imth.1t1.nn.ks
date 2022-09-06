extern console

class Hello {
	hello(name: String): String => `Hello \(name).`
}

class Proxy {
	private @component: Hello = new Hello()

	proxy hello = @component.hello
}

var proxy = new Proxy()

console.log(`\(proxy.hello('Joe'))`)

export Proxy