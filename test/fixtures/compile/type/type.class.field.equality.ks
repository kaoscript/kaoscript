class Foobar {
}

class Quxbaz extends Foobar {
	quxbaz() {
	}
}

class Corge {
	private {
		@foo: Foobar	= Foobar.new()
	}
	qux() {
		if @foo is Quxbaz {
			@foo.quxbaz()
		}
	}
}