class Foobar {
	private {
		@x: Number
	}
	constructor(data) {
		match data {
			'x' {
				@x = 1
			}
		}
	}
}