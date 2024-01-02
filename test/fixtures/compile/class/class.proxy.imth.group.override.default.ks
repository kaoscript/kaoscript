class Hello {
	hello(name: String): String => `Hello \(name).`
}

class Proxy extends Hello {
	private {
		@component: Hello = Hello.new()
	}

	override hello(name) => `Hi \(name).`

	proxy @component {
		hello
	}
}