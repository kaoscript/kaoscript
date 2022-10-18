extern console

class Hello {
	goodbye(name: String): String => `Goodbye \(name).`
	welcome(name: String): String => `welcome \(name).`
}

class Proxy {
	private @component: Hello = new Hello()

	proxy @component {
		goodbye
		hello
		welcome
	}
}

var proxy = new Proxy()

console.log(`\(proxy.goodbye('Joe'))`)

export Proxy