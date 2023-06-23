func foobar(value) {
	var box = value.box()

	return {
		value: func() => box.value()
	}
}