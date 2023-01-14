class Foobar {
	private {
		@x: Number		= 0
	}
	constructor(data) {
		match data {
			'x' {
				@x = 1
			}
		}
	}
}