class Foobar {
	private {
		@x: Number
	}
	constructor(data) {
		switch data {
			'x' => {
				@x = 1
			}
			=> {
				@x = 0
			}
		}
	}
}