func foobar(value) {
	if value.isTest() {
		var box = value.box()

		return {
			value: func() {
				return box.value()
			}
		}
	}
}