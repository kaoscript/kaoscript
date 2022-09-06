extern console

class Hello {
	goodbye(name: String): String => `Goodbye \(name).`
	hello(name: String): String => `Hello \(name).`
	welcome(name: String): String => `welcome \(name).`
}

class Proxy {
	private @component: Hello = new Hello()

	proxy @component {
		goodbye =>	g
		hello =>	h
		welcome =>	w
	}
}

var proxy = new Proxy()

console.log(`\(proxy.h('Joe'))`)

export Proxy