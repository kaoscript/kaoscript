class Foobar {
}

class Quxbaz extends Foobar {
	quxbaz() {
	}
}

class Corge {
	private {
		@foo: Foobar
	}
	qux() {
		if @foo is Quxbaz {
			@foo.quxbaz()
		}
	}
}