extern console

class Hello {
}

class Proxy {
	private @component: Hello = Hello.new()

	proxy hello = @component.hello
}

var proxy = Proxy.new()

console.log(`\(proxy.hello('Joe'))`)

export Proxy