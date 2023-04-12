class Foobar {
	private {
		@values: String[]
	}
	constructor(...@values) {
	}
}

var f = Foobar.new('a', 'b', 'c')