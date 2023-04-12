class Foobar {
	private {
		@x: Number
	}
	constructor(test) ~ Error {
		if test {
			throw Error.new('failed')
		}
		else {
			@x = 24
		}
	}
}