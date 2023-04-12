class Foo {
	toString(): String => 'foo'
}

class Bar {
	private {
		_foo: Foo?
	}
	constructor(@foo)
	foo(): Foo? => @foo
}

class Qux extends Bar {
	constructor() {
		super(Foo.new())
	}
}

export Qux