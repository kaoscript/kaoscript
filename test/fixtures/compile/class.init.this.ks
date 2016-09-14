class Foo {
	Foo(bar) {
	}
}

class Bar {
	private {
		_foo: Foo = new Foo(this)
	}
}