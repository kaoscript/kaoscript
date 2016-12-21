class Foo {
	$create(bar) {
	}
}

class Bar {
	private {
		_foo: Foo = new Foo(this)
	}
}