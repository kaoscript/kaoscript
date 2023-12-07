class Foobar {
	public {
		@flag: Boolean		= false
	}
	foobar(data) {
		var value =
			if data.kind == 0 {
				this.flag = true

				set 0
			}
			else {
				set 1
			}
	}
}