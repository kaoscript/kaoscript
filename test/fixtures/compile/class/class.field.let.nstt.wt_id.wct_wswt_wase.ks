class Foobar {
	private {
		@x: Number		= 0
	}
	constructor(data) {
		switch data {
			'x' => {
				@x = 1
			}
		}
	}
}