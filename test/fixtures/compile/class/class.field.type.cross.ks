extern console: {
	log(...args)
}

class Foo {
	private {
		late _bar: Bar
	}
	bar(): Bar => this._bar
	bar(@bar) => this
}

class Bar {
	private {
		late _foo: Foo
	}
	foo(): Foo => this._foo
	foo(@foo) => this
}