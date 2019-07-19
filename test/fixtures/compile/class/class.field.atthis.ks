class Foobar {
	private @foo: Number	= 42
	public @bar: String		= 'foobar'

	foo() => @foo
	foo(@foo) => this
}