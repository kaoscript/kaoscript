func foobar(value) {
	var box = value.box()

	return {
		value() => box.value()
	}
}