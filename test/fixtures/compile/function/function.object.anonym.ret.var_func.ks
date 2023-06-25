func foobar(value) {
	var box = value.box()

	return {
		value: func() {
			return box.value()
		}
	}
}