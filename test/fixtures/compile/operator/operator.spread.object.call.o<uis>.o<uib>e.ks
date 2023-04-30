func foobar(values: Object<Number | String>) {
	var copy = { ...values }

	quxbaz(copy)
}

func quxbaz(values: Object<Number | Boolean>) {
}