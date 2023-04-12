class Foobar {
	private {
		@x: Number
	}
	constructor(value) ~ Error {
		match value {
			0..9 {
				@x = 0
			}
			else {
				throw Error.new('foobar')
			}
		}
	}
}