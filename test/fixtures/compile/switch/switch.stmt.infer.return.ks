func foobar(x) {
	var dyn value
	switch x {
		0, 1 => {
			value = 'binary'
		}
		=> {
			return null
		}
	}

	quxbaz(value)
}

func quxbaz(value) {
}