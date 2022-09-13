class Foobar {
	private late {
		@quxbaz: Quxbaz
	}
	proxy quxbaz = @quxbaz.quxbaz
}

class Quxbaz {
	quxbaz() => 0
}