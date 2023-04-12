extern console

class Hello {
	hello(name: String): String => `Hello \(name).`
}

class Proxy {
	private @component: Hello = Hello.new()

	proxy hello = @component.hello
}

var proxy = Proxy.new()

console.log(`\(proxy.hello('Joe'))`)

export Proxy