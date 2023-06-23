func foobar(value) {
	if value.isTest() {
		var box = value.box()

		return {
			value() {
				return box.value()
			}
		}
	}
}