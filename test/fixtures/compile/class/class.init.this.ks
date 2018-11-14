class Foo {
	constructor(bar) {
	}
}

class Bar {
	private {
		_foo: Foo = new Foo(this)
	}
}