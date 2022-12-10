class Foobar {
	private {
		@values: String[]
	}
	constructor(...@values) {
	}
}

var f = new Foobar('a', 'b', 'c')