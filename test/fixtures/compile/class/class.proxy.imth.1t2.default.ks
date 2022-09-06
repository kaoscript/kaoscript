class Hello {
	hello(x: Number) {
	}
	hello(x: String) {
	}
}

class Proxy {
	private {
		@component: Hello
	}
	constructor(@component)
	proxy @component {
		hello
	}
}

var p = new Proxy(new Hello())

p.hello('')
p.hello(42)