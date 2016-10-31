extern console: {
	log(...args)
}

class Foo {
	private {
		_bar: Bar
	}
	
	bar() -> Bar => this._bar
	bar(@bar: Bar) => this
}

class Bar {
	private {
		_foo: Foo
	}
	foo() -> Foo => this._foo
	foo(@foo: Foo) => this
}