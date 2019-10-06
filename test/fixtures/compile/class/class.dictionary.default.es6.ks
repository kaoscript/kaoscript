class Foobar {
	private {
		_x
		_y
		_z
	}
	data() {
		@z = 1

		return {
			@x
			@y
			power: {
				@z
			}
		}
	}
}