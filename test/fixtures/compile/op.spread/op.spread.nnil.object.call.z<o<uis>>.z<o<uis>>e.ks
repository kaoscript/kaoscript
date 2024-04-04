type Values = Object<Number | String>

func foobar(values: Values) {
	var copy = { ...values }

	quxbaz(copy)
}

func quxbaz(values: Values) {
}