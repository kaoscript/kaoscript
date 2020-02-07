class Foobar {
	private {
		@x: Number
	}
	constructor(values) {
		for const value in values {
			@x = value
		}
	}
}