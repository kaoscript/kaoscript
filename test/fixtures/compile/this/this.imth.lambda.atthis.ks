class Foobar {
	private {
		@foobar
	}
	foobar() {
		var fn = (data) => new Quxbaz(data, @foobar)
	}
}

class Quxbaz {
	constructor(data, foobar) {
	}
}