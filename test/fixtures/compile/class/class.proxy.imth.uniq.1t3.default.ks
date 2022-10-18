extern console

class Hello {
	hello(name: String): String => `Hello \(name).`
	hello(index: Number): String => `Yep, I can count until \(index).`
	hello(value: Boolean): Boolean => value
}

class Proxy {
	private @component: Hello = new Hello()

	proxy hello = @component.hello
}

var proxy = new Proxy()

console.log(`\(proxy.hello('Joe'))`)
console.log(`\(proxy.hello(42))`)
console.log(`\(proxy.hello(true))`)

export Proxy