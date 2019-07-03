class Foobar {

}

class Quxbaz {
	private {
		_options = {
			class: Foobar
		}
	}
	new() {
		const foo = new @options.class()
	}
}