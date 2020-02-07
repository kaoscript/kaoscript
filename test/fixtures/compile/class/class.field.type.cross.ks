extern console: {
	log(...args)
}

class Foo {
	private {
		lateinit _bar: Bar
	}
	bar(): Bar => this._bar
	bar(@bar) => this
}

class Bar {
	private {
		lateinit _foo: Foo
	}
	foo(): Foo => this._foo
	foo(@foo) => this
}