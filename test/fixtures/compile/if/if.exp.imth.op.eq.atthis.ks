class Foobar {
	private {
		@flag: Boolean		= false
	}
	foobar(data) {
		var value =
			if data.kind == 0 {
				@flag = true

				set 0
			}
			else {
				set 1
			}
	}
}