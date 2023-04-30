type NS = Object<Number | String>
type NB = Object<Number | Boolean>

func foobar(values: NS) {
	var copy = { ...values }

	quxbaz(copy)
}

func quxbaz(values: NB) {
}