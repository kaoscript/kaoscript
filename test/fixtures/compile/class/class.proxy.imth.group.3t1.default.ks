extern console

class Hello {
	goodbye(name: String): String => `Goodbye \(name).`
	hello(name: String): String => `Hello \(name).`
	welcome(name: String): String => `welcome \(name).`
}

class Proxy {
	private @component: Hello = Hello.new()

	proxy @component {
		goodbye
		hello
		welcome
	}
}

var proxy = Proxy.new()

console.log(`\(proxy.hello('Joe'))`)

export Proxy