extern console

class Hello {
}

class Proxy {
	private @component: Hello = new Hello()

	proxy hello = @component.hello
}

var proxy = new Proxy()

console.log(`\(proxy.hello('Joe'))`)

export Proxy