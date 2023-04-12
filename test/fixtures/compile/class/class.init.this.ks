class Foo {
	constructor(bar) {
	}
}

class Bar {
	private {
		_foo: Foo = Foo.new(this)
	}
}