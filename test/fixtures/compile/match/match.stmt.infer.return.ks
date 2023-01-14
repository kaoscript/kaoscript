func foobar(x) {
	var dyn value
	match x {
		0, 1 {
			value = 'binary'
		}
		else {
			return null
		}
	}

	quxbaz(value)
}

func quxbaz(value) {
}