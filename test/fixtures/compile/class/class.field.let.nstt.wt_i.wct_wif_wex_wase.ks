class Foobar {
	private {
		@x: Number
	}
	constructor(test) ~ Error {
		if test {
			throw new Error('failed')
		}
		else {
			@x = 24
		}
	}
}