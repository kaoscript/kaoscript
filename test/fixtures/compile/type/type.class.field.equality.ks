class Foobar {
}

class Quxbaz extends Foobar {
	quxbaz() {
	}
}

class Corge {
	private {
		@foo: Foobar	= new Foobar()
	}
	qux() {
		if @foo is Quxbaz {
			@foo.quxbaz()
		}
	}
}