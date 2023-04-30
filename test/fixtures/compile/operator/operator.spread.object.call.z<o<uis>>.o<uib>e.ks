type NS = Object<Number | String>

func foobar(values: NS) {
	var copy = { ...values }

	quxbaz(copy)
}

func quxbaz(values: Object<Number | Boolean>) {
}