class Foobar {
	private {
		@x: Number
	}
	constructor(test) ~ Error {
		if test {
			@x = 42
		}
		else {
			throw Error.new('failed')
		}
	}
}